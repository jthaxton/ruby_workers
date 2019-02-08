# implement command line option
require 'byebug'

class Search
    def initialize(options)
        @options = options
        @time_lim = options[:time]
    end

    def start
        STDIN.each do |line|
            @break_out = false
            puts threader(line, @options)
            break if @break_out == true 
        end
    end 

    def threader(line, elapsed_time=0, byte_count=0, time_lim)
    thread_result = []
        # generate threads
        10.times do |t|
            sub = []
            Thread.new {sub << searcher(line, elapsed_time, byte_count, @time_lim)}
            thread_result += sub
        end 
         aggregate_result = [0,0,@status]
        
        #  sum results from each thread together
        thread_result.each do |el|
            aggregate_result[0] += el[0]
            aggregate_result[1] += el[1]
            aggregate_result[2] = @status
        end 
        if aggregate_result[0] > @options[:time].to_i
            @break_out = true 
        end 
        ["ELAPSED TIME: #{aggregate_result[0]}", "BYTE COUNT: #{aggregate_result[1]}", "STATUS: #{aggregate_result[2]}"]
    end

    def searcher(line, elapsed_time, byte_count, time_lim)
        old_time = Time.now
        @status = "UNSUCCESSFUL"
        # break out of Search#start if 'Lpfn' found
        if line.include?('Lpfn')
            @status = "SUCCESS" 
            @break_out = true

            # break out of Search#start if TIMEOUT
        elsif Time.now - old_time >= time_lim.to_i
            @status = "TIMEOUT"
            @break_out = true
        end 
        new_time = Time.now 
        delta = new_time - old_time
        elapsed_time += delta
        report = [elapsed_time, line.bytesize, @status]
        report
    end 
end 
