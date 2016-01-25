require 'trollop'

module SensuWrapper
  class Options
    def options
      opts = Trollop::options do
        version "sensu-wrapper 0.0.1 Lee Briggs"
          banner <<-EOS
A little ruby script that wraps commands and sends the result to a sensu socket

Usage:
EOS
        opt :name, "Name of check", :type => :string, :required => true
        opt :command, "The command to run", :type => :string, :required => true
        opt :dry_run, "Output to stdout"
        opt :handler, "Which handlers to use on the event", :type => :string, :multi => true, :short => "-H"
        opt :ttl, "How often should we hear from this check", :type => :int, :short => "-T"
        opt :source, "Where should this check come from?", :type => :string
        opt :extra, "Extra fields you'd like to include in the form of ruby hash mappings", :type => :string, :multi => true
        opt :nagios, "Nagios compliant", :short => "-N"
        opt :timeout, "Timeout command execution after number of s", :type => :int, :default => 10
      end
    end
  end
end
