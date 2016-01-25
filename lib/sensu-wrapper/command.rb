require 'open3'
require 'timeout'
require 'safe_timeout'

module SensuWrapper
  class Command
    attr_accessor :cmd
    attr_accessor :t #timeout
    attr_reader :output
    attr_reader :result
    attr_reader :pid

    def run_system_command
      begin
        SafeTimeout.timeout(t) do
          stdout, stdeerr, status = Open3.capture3(cmd)
          @output = stdout
          @result = status.exitstatus
          @pid = status.pid
          @timeout = t
        end
      rescue Errno::ENOENT
        abort("Error: #{cmd} not found")
      rescue Timeout::Error
        @output = "command timed out"
        @result = 2
        @timeout = t
      end
    end
  end

end
