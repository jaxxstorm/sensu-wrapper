require 'socket'
require 'json'

module SensuWrapper
  class Socket
    attr_accessor :message

    def send_udp_message
      udp = UDPSocket.new
      udp.send(message, 0, '127.0.0.1', 3030)
    end
  end
end
