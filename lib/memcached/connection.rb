require File.expand_path('../request_parser', __FILE__)
require File.expand_path('../commands', __FILE__)

# This class accepts and responds the incoming requests of
# the clients and stores the timestamp of each get/gets
# request
class Connection
  attr_accessor :memcached, :client, :fetched_records_time

  # Creates a new Connection instance
  # Params:
  # +memcached+:: instance of memcached class
  # +client+:: client connection
  def initialize(memcached, client)
    @memcached = memcached
    @client = client
    @fetched_records_time = {}
  end

  # Listen and responds client requests
  def accept_requests
    while client
      request = client.recv(1024)
      if request == 'quit'
        puts 'Received: quit, closed connection'
        client.close
        break
      elsif !request.nil?
        params = RequestParser.parse(request)
        params[:fetched_records_time] = fetched_records_time
        result = memcached.process(params)
        save_fetched_keys(params)
        client.write result
      end
    end
  end

  private

  # Saves the time when a record is fetched
  # Params:
  # +params+:: parameters of the request
  def save_fetched_keys(params)
    if Command::RETRIEVAL_COMMANDS.include?(params[:command])
      params[:keys].each { |key| fetched_records_time[key.to_sym] = Time.now }
    end
  end
end
