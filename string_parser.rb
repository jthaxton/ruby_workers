require 'pp'
class Search
    def initialize(options)
        @time_lim = options[:time].to_i
        @break_out = false
        @store = [] 
        @total_time = 0
        @file = options[:file]
        @total_bytes = 0
    end

    def start
        if @file 
            populate_store(nil)
            pp pretty_output
            @store.each do |thread|
                next if thread[2] != 'SUCCESS' 
                @total_time += thread[0]
                @total_bytes += thread[1]
            end
            puts "AVERAGE BYTES/SEC: #{@average}"
            @store = []
            if @total_time > @time_lim
                puts "TIMEOUT"
                return
            end
        else
            STDIN.each do |line|
                populate_store(line)
                pp pretty_output
                puts "AVERAGE BYTES/SEC: #{@average}"
                @store = []
                if  @total_time > @time_lim
                    puts "TIMEOUT"
                    break
                elsif @break_out == true 
                    break
                end
            end
        end
    end

    private

        def pretty_output
            result = []
            @store.each do |el|
                result << ["ELAPSED TIME: #{el[2] == "FAILURE" ||
                 el[2] == "TIMEOUT" ? "N/A" : el[0]}","COUNT OF BYTES READ: #{el[2] == "FAILURE" ||
                  el[2] == "TIMEOUT" ? "N/A" : el[1]}", "STATUS: #{el[2]}"]
            end
            total_time = 0 
            total_bytes = 0
            @store.each do |el|
                if el[0].class != String && el[2] == "SUCCESS"
                    total_time += el[0]
                end 
                if el[1].class != String && el[2] == "SUCCESS"
                    total_bytes += el[1]
                end 
            end 
            @average = (total_time == 0 ? "NA" : total_bytes / total_time)
            result
        end 

        def populate_store(line)
            if @file
                threads = []
                10.times do |t|
                    threads << Thread.new do
                        read = File.open(@file, 'r')
                        result = [0, 0, 'FAILURE']
                        read.each_line do |line|  
                            temp = search_stream(line, 0, 0, @time_lim)
                            result[0] += temp[0]
                            @total_time += temp[0]
                            @total_bytes += temp[1]
                            if result[0] > @time_lim
                                result = [0, 0, 'TIMEOUT']
                                break
                            elsif result[2] == 'FAILURE'
                                result = [0,0,'FAILURE']
                            end
                            result[1] += temp[1]
                            if temp[2] == 'SUCCESS'
                                result[2] = 'SUCCESS'
                                break
                            end
                        end
                        result
                    end
                end
                @store = threads.map(&:value)
                @store = @store.sort { |e,f| f[0] <=> e[0] }
            else
                @break_out = false 
                @store = create_threads(line, 0, 0, @time_lim)
                @store = @store.sort { |e,f| f[0] <=> e[0] }
            end
        end

        def search_stream(line, elapsed_time, byte_count, time_lim)
            old_time = Time.now
            @status = "FAILURE"
            if line.include?('Lpfn')
                @status = "SUCCESS" 
                @break_out = true
            elsif Time.now - old_time >= @time_lim.to_i
                @status = "TIMEOUT"
                @break_out = true
            end 
            new_time = Time.now 
            delta = new_time - old_time
            elapsed_time += delta
            byte_count += byte_count(line)
            status_report_arr = [elapsed_time,byte_count, @status]
            status_report_arr
        end

        def create_threads(line, elapsed_time=0, byte_count=0, time_lim)
            threads = []
            10.times do |t|
                threads << Thread.new do 
                    search_stream(line, elapsed_time, byte_count, @time_lim)
                end
            end
            thread_result = threads.map(&:value)
            aggregate_result = [0,0,@status]
            thread_result.each do |el|
                @break_out = true if @total_time > @time_lim
                @total_time += el[0]
                @total_bytes += el[1]
                aggregate_result[2] = @status
            end 
            thread_result
        end

        def byte_count(line)
            read_str = ''
            i = 0 
            while i < line.length - 3
                if line[i..i + 3] == 'Lpfn'
                    read_str += line[i..i + 3]
                    break
                else 
                    read_str += line[i]
                end 
                i += 1 
            end 
            @total_bytes += read_str.bytesize()
            return read_str.bytesize()
        end 
end 
