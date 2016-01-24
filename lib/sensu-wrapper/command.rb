require 'open3'

module SensuWrapper
  class Command
    attr_accessor :cmd
    attr_reader :output
    attr_reader :result
    attr_reader :pid

    def run_system_command
      begin
        stdout, stdeerr, status = Open3.capture3(cmd)
        @output = stdout
        @result = status.exitstatus
        @pid = status.pid
      rescue Errno::ENOENT
        abort("Error: #{cmd} not found")
      end
    end
  end

end
