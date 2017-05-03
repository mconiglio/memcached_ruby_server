require 'socket'
require File.expand_path('../../memcached', __FILE__)
require File.expand_path('../connection', __FILE__)

# This class listen on the defined port and creates a
# instance of Connection class creating a TCP connection
class MemcachedServer
  attr_reader :server, :port

  # Creates a new MemcachedServer instance
  # Params:
  # +port+:: port number
  def initialize(port)
    @port = port
    @server =
      begin
        TCPServer.new(@port)
      rescue SystemCallError => e
        raise "Can't create tcp server on port #{@port}: #{e}"
      end
  end

  # Creates a connection for incoming requests
  def start
    memcached = Memcached.new
    puts "Listening on port #{port}...\n"
    loop do
      Thread.start(server.accept) do |client|
        begin
          Connection.new(memcached, client).accept_requests
        ensure
          client.close if client?
          puts 'Closing connection'
        end
      end
    end
  end
end
