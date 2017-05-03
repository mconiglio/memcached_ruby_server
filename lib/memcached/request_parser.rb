require File.expand_path('../commands', __FILE__)

# This class parses the incoming requests
module RequestParser
  module_function

  # Parses a request and returns a hash with the parameters
  # Params:
  # +request+:: string value with the request
  def parse(request)
    lines = request.split("\r\n")
    tokens = lines.first.split
    params = {}
    params[:command] = tokens.first

    case params[:command]
    when *Commands::STORAGE_COMMANDS
      params[:key] = tokens[1]
      params[:flags] = tokens[2]
      params[:ttl] = tokens[3].to_i
      params[:unique_cas_token] = tokens[4].to_i unless tokens[4].nil?
      params[:value] = lines[1]
    when *Commands::RETRIEVAL_COMMANDS
      params[:keys] = []
      tokens[1..-1].each do |key|
        next if key.empty?
        params[:keys] << key
      end
    end
    params
  end
end
