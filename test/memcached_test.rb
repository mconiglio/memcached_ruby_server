require File.expand_path('../../lib/memcached', __FILE__)
require 'test/unit'

class MemcachedTest < Test::Unit::TestCase
  def setup
    @memcached = Memcached.new
    @set_sample = { command: 'set', key: 'key', flags: '0', ttl: 10, value: 'value' }
    @other_set_sample = { command: 'set', key: 'otherkey', flags: '1', ttl: 10, value: 'othervalue' }
    @get_sample = { command: 'get', keys: ['key'] }
  end

  def test_setting_record_returns_stored
    result = @memcached.process(@set_sample)
    assert_equal("STORED\r\n", result)
    result = @memcached.process(@get_sample)
    assert_equal("VALUE key 0 \r\nvalue\r\nEND\r\n", result)
  end

  def test_adding_existing_record_returns_not_stored
    @memcached.process(@set_sample)
    add_params = { command: 'add', key: 'key', flags: '0', ttl: 1, value: 'value' }
    result = @memcached.process(add_params)
    assert_equal("NOT_STORED\r\n", result)
  end

  def test_adding_unexisting_record_returns_stored
    add_params = { command: 'add', key: 'key', flags: '0', ttl: 1, value: 'value' }
    result = @memcached.process(add_params)
    assert_equal("STORED\r\n", result)
  end

  def test_replacing_existing_record_returns_stored
    @memcached.process(@set_sample)
    replace_params = { command: 'replace', key: 'key', flags: '0', ttl: 1, value: 'value' }
    result = @memcached.process(replace_params)
    assert_equal("STORED\r\n", result)
  end

  def test_replacing_unexisting_record_returns_not_stored
    replace_params = { command: 'replace', key: 'key', flags: '0', ttl: 1, value: 'value' }
    result = @memcached.process(replace_params)
    assert_equal("NOT_STORED\r\n", result)
  end

  def test_appending_existing_record_returns_stored
    @memcached.process(@set_sample)
    append_params = { command: 'append', key: 'key', flags: '0', ttl: 1, value: 'other' }
    result = @memcached.process(append_params)
    assert_equal("STORED\r\n", result)
    result = @memcached.process(@get_sample)
    assert_equal("VALUE key 0 \r\nvalueother\r\nEND\r\n", result)
  end

  def test_appending_unexisting_record_returns_not_stored
    append_params = { command: 'replace', key: 'key', flags: '0', ttl: 1, value: 'value' }
    result = @memcached.process(append_params)
    assert_equal("NOT_STORED\r\n", result)
  end

  def test_prepending_existing_record_returns_stored
    @memcached.process(@set_sample)
    prepend_params = { command: 'prepend', key: 'key', flags: '0', ttl: 1, value: 'other' }
    result = @memcached.process(prepend_params)
    assert_equal("STORED\r\n", result)
    result = @memcached.process(@get_sample)
    assert_equal("VALUE key 0 \r\nothervalue\r\nEND\r\n", result)
  end

  def test_prepending_unexisting_record_returns_not_stored
    prepend_params = { command: 'replace', key: 'key', flags: '0', ttl: 1, value: 'value' }
    result = @memcached.process(prepend_params)
    assert_equal("NOT_STORED\r\n", result)
  end

  def test_casing_unmodified_record_returns_stored
    @memcached.process(@set_sample)
    object_id = @memcached.storage[@set_sample[:key]].object_id
    cas_params = {
      command: 'cas',
      key: 'key',
      flags: '0',
      ttl: 1,
      value: 'other',
      unique_cas_token: object_id,
      fetched_records_time: { key: Time.now }
    }
    result = @memcached.process(cas_params)
    assert_equal("STORED\r\n", result)
  end

  def test_casing_modified_record_returns_exists
    @memcached.process(@set_sample)

    time_before_updating = Time.now
    append_params = { command: 'append', key: 'key', flags: '0', ttl: 1, value: 'other' }
    @memcached.process(append_params)

    object_id = @memcached.storage[@set_sample[:key]].object_id
    cas_params = {
      command: 'cas',
      key: 'key',
      flags: '0',
      ttl: 1,
      value: 'other',
      unique_cas_token: object_id,
      fetched_records_time: { key: time_before_updating }
    }
    result = @memcached.process(cas_params)
    assert_equal("EXISTS\r\n", result)
  end

  def test_casing_record_without_unique_token_returns_error
    cas_params = {
      command: 'cas',
      key: 'key',
      flags: '0',
      ttl: 1,
      value: 'other',
      fetched_records_time: { key: Time.now }
    }
    result = @memcached.process(cas_params)
    assert_equal("ERROR\r\n", result)
  end

  def test_sending_wrong_parameters_returns_error
    wrong_params = {
      command: 'wrong_command',
      key: 'errorkey',
      flags: '',
      ttl: 1,
      value: 'errorvalue'
    }
    result = @memcached.process(wrong_params)
    assert_equal("ERROR\r\n", result)
  end

  def test_getting_existing_record_returns_value
    @memcached.process(@set_sample)
    result = @memcached.process(@get_sample)
    assert_equal("VALUE key 0 \r\nvalue\r\nEND\r\n", result)
  end

  def test_getting_unexisting_record_returns_not_found
    result = @memcached.process(@get_sample)
    assert_equal("NOT_FOUND\r\n", result)
  end

  def test_getting_multiple_keys_returns_values
    @memcached.process(@set_sample)
    @memcached.process(@other_set_sample)
    get_params = { command: 'get', keys: ['key', 'otherkey'] }
    result = @memcached.process(get_params)
    assert_equal("VALUE key 0 \r\nvalue\r\nVALUE otherkey 1 \r\nothervalue\r\nEND\r\n", result)
  end

  def test_getting_cas_record_returns_values_with_unique_token
    @memcached.process(@set_sample)
    object_id = @memcached.storage[@set_sample[:key]].object_id
    gets_params = { command: 'gets', keys: ['key'] }
    result = @memcached.process(gets_params)
    assert_equal("VALUE key 0 #{object_id}\r\nvalue\r\nEND\r\n", result)
  end
end
