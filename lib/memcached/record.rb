require 'thread'

# This class stores the attributes of a record and
# operates on them
class Record
  attr_accessor :value, :flags, :ttl, :mutex, :saved_at

  # Creates a new Record instance
  # Params:
  # +params+:: parameters of the record to create
  def initialize(params)
    @mutex = Mutex.new
    @value = params[:value]
    @flags = params[:flags]
    @ttl = params[:ttl]
    update_record_time
  end

  # Replaces the attributes of a record
  # Params:
  # +params+:: parameters of the record to replace
  def replace_value(params)
    mutex.synchronize do
      self.value = params[:value]
      self.flags = params[:flags]
      self.ttl = params[:ttl]
      update_record_time
    end
  end

  # Appends a value to the existing value
  # Params:
  # +value+:: value to append to the existing Record value
  def append_value(value)
    mutex.synchronize do
      self.value << value
      update_record_time
    end
  end

  # Prepends a value to the existing value
  # Params:
  # +value+:: value to prepend to the existing Record value
  def prepend_value(value)
    mutex.synchronize do
      self.value = value << self.value
      update_record_time
    end
  end

  # Returns a string with the attributes of a Record instance
  # Params:
  # +show_token+:: boolean value that indicates if the string
  #   returned has the object_id
  def to_s(show_token)
    "#{flags} #{object_id if show_token}\r\n#{value}"
  end

  # Returns a boolean value indicating if the record is expired
  def expired?
    if ttl == 0
      false
    else
      saved_at + ttl <= Time.now
    end
  end

  private

  # Updates the record saved time
  def update_record_time
    self.saved_at = Time.now
  end
end
