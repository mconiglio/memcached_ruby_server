require File.expand_path('../memcached/record', __FILE__)

# This class stores the records associated to each key
# and executes the parsed requests
class Memcached
  attr_accessor :storage

  # Creates a new Memcached instance
  def initialize
    @storage = {}
  end

  # Processes the parsed request and returns an error message
  # if the command is not supported
  # Params:
  # +params+:: hash with the parameters of the request
  def process(params)
    delete_expired_records
    send(params[:command] + '_record', params)
  rescue
    "ERROR\r\n"
  end

  private

  # Sets the record associated to the key given on the parameters
  # Params:
  # +params+:: hash with the parameters of the request
  def set_record(params)
    storage[params[:key]] = Record.new(params)
    "STORED\r\n"
  end

  # Adds the record associated to the key given on the parameters
  # Params:
  # +params+:: hash with the parameters of the request
  def add_record(params)
    if storage.key?(params[:key])
      "NOT_STORED\r\n"
    else
      set_record(params)
    end
  end

  # Replaces the record associated to the key given on the parameters
  # Params:
  # +params+:: hash with the parameters of the request
  def replace_record(params)
    if storage.key?(params[:key])
      storage[params[:key]].replace_value(params)
      "STORED\r\n"
    else
      "NOT_STORED\r\n"
    end
  end

  # Appends the value given on the parameters to the value associated
  # to the key
  # Params:
  # +params+:: hash with the parameters of the request
  def append_record(params)
    if storage.key?(params[:key])
      storage[params[:key]].append_value(params[:value])
      "STORED\r\n"
    else
      "NOT_STORED\r\n"
    end
  end

  # Prepends the value given on the parameters to the value associated
  # to the key given on the parameters
  # Params:
  # +params+:: hash with the parameters of the request
  def prepend_record(params)
    if storage.key?(params[:key])
      storage[params[:key]].prepend_value(params[:value])
      "STORED\r\n"
    else
      "NOT_STORED\r\n"
    end
  end

  # Sets the record associated to the key given on the parameters
  # if it was not modified since the requesting client last fetched it
  # for last time
  # Params:
  # +params+:: hash with the parameters of the request
  def cas_record(params)
    return "ERROR\r\n" if params[:unique_cas_token].nil?
    return "NOT_FOUND\r\n" unless storage.key?(params[:key])
    record_was_modified = storage[params[:key]].saved_at > params[:fetched_records_time][params[:key].to_sym]
    return "EXISTS\r\n" if record_was_modified
    if params[:unique_cas_token] == storage[params[:key]].object_id
      replace_record(params)
      "STORED\r\n"
    else
      "NOT_STORED\r\n"
    end
  end

  # Returns the information about the records associated to the keys
  # given in the parameters except the unique_cas_token
  # Params:
  # +params+:: hash with the parameters of the request
  def get_record(params, show_token = false)
    output = ''
    params[:keys].each do |key|
      output << "VALUE #{key} #{storage[key].to_s(show_token)}\r\n" if storage.key?(key)
    end
    if output.empty?
      "NOT_FOUND\r\n"
    else
      output + "END\r\n"
    end
  end

  # Returns the information about the records associated to the keys
  # given in the parameters including the unique_cas_token
  # Params:
  # +params+:: hash with the parameters of the request
  def gets_record(params)
    get_record(params, true)
  end

  # Deletes the stored expired records
  def delete_expired_records
    storage.delete_if { |key, record| record.expired? }
  end
end
