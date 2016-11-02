require 'sensu-wrapper/options'
require 'sensu-wrapper/command'
require 'sensu-wrapper/socket'
require 'json'

module SensuWrapper
  class Base
    attr_accessor :cli

    def run
      self.cli = Options.new.options
      check = SensuWrapper::Command.new
      check.cmd = cli.command # assign the check cmd from the cli class
      check.t = cli.timeout if cli.timeout # assign the timeout from the cli class
      check.run_system_command
      command_result = check.result
      check_duration = check.duration if check.duration
    
      unless cli.nagios
        if command_result != 0
          command_result = 2
        end
      end

      sensu_hash = {
        "name" => cli.name,
        "command" => cli.command,
        "status" => command_result,
        "output" => check.output,
        "handler" => cli.handler,
        "ttl" => cli.ttl,
        "source" => cli.source,
        "pid" => check.pid,
        "timeout" => check.t,
        "duration" => check_duration.round(2),
      }.reject { |k, v| v.nil? }

      if cli.extra
        cli.extra.each do |value|
          sensu_hash.merge!(eval("{ #{value} }"))
        end
      end

      # Shall we send an event or not?
      if cli.dry_run
        puts sensu_hash.to_json
      else
        socket = SensuWrapper::Socket.new
        socket.message = sensu_hash.to_json
        socket.send_udp_message
      end
    end
  end
end
