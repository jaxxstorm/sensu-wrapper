require 'open3'
require 'timeout'
require 'safe_timeout'

module SensuWrapper
  class Command
    attr_accessor :cmd
    attr_accessor :t #timeout
    attr_reader :duration
    attr_reader :output
    attr_reader :result
    attr_reader :pid

    # Taken and modified from here: https://gist.github.com/pasela/9392115
    def capture3_with_timeout(*cmd)
      spawn_opts = Hash === cmd.last ? cmd.pop.dup : {}
      opts = {
        :stdin_data => spawn_opts.delete(:stdin_data) || "",
        :binmode    => spawn_opts.delete(:binmode) || false,
        :timeout    => spawn_opts.delete(:timeout) || @t,
        :signal     => spawn_opts.delete(:signal) || :TERM,
        :kill_after => spawn_opts.delete(:kill_after),
      }
      
      in_r,  in_w  = IO.pipe
      out_r, out_w = IO.pipe
      err_r, err_w = IO.pipe
      in_w.sync = true

      if opts[:binmode]
        in_w.binmode
        out_r.binmode
        err_r.binmode
      end

      spawn_opts[:in]  = in_r
      spawn_opts[:out] = out_w
      spawn_opts[:err] = err_w

      result = {
        :pid        => nil,
        :status     => nil,
        :stdout     => nil,
        :stderr     => nil,
        :exitstatus => nil,
        :timeout    => false,
      }
      
      out_reader = nil
      err_reader = nil
      wait_thr = nil
      begin
        Timeout.timeout(opts[:timeout]) do
        result[:pid] = spawn(*cmd, spawn_opts)
        wait_thr = Process.detach(result[:pid])
        in_r.close
        out_w.close
        err_w.close

        out_reader = Thread.new { out_r.read }
        err_reader = Thread.new { err_r.read }

        in_w.write opts[:stdin_data]
        in_w.close

        result[:status] = wait_thr.value
        result[:exitstatus] = wait_thr.value.exitstatus
        end
      rescue Timeout::Error
        result[:timeout] = true
        pid = spawn_opts[:pgroup] ? -result[:pid] : result[:pid]
        Process.kill(opts[:signal], pid)
        if opts[:kill_after]
          unless wait_thr.join(opts[:kill_after])
            Process.kill(:KILL, pid)
          end
        end
      ensure
        result[:status] = wait_thr.value if wait_thr
        result[:stdout] = out_reader.value if out_reader
        result[:stderr] = err_reader.value if err_reader
        out_r.close unless out_r.closed?
        err_r.close unless err_r.closed?
      end
      result
    end


    def run_system_command
      begin
        block = proc do
          result = capture3_with_timeout(cmd)
          if result[:stdout].empty?
            if result[:timeout]
              @output = "command timed out"
            else
              @output = "command returned to stdout"
            end
          else
            @output = result[:stdout]
          end
          @result = result[:exitstatus] || 2
        end
        startTime = Time.now
        block.call
        @duration = Time.now - startTime
      rescue Errno::ENOENT
        abort("Error: #{cmd} not found")
      end
    end
  end

end
