# implement command line option
def threader(line, options, elapsed_time=0, byte_count=0, time_lim=10)
    result = []
    10.times do |t|
        sub = []
        Thread.new {sub << searcher(line, options, elapsed_time, byte_count, time_lim)}
        result << sub
    end 
    result
end

def searcher(line, options, elapsed_time, byte_count, time_lim)
    old_time = Time.now
    status = "UNSUCCESSFUL"
    if line.include?('Lpfn')
        status = "SUCCESS" 
    elsif Time.now - old_time >= time_lim
        status = "TIMEOUT"
    end 
    new_time = Time.now 
    delta = new_time - old_time
    elapsed_time += delta
    report = [elapsed_time, line.bytesize, status]
    return report
end 

def start(options)
    ARGF.each do |line|
        puts threader(line, options)
    end
end 