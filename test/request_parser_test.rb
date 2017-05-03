require File.expand_path('../../lib/memcached/request_parser', __FILE__)
require 'test/unit'

class RequestParserTest < Test::Unit::TestCase
  def test_parsing_set
    request = "set key 1 100\r\nvalue"
    params = RequestParser.parse(request)
    assert_equal('set', params[:command])
    assert_equal('key', params[:key])
    assert_equal('1', params[:flags])
    assert_equal(100, params[:ttl])
    assert_equal('value', params[:value])
  end

  def test_parsing_add
    request = "add key 1 100\r\nvalue"
    params = RequestParser.parse(request)
    assert_equal('add', params[:command])
    assert_equal('key', params[:key])
    assert_equal('1', params[:flags])
    assert_equal(100, params[:ttl])
    assert_equal('value', params[:value])
  end

  def test_parsing_replace
    request = "replace key 1 100\r\nvalue"
    params = RequestParser.parse(request)
    assert_equal('replace', params[:command])
    assert_equal('key', params[:key])
    assert_equal('1', params[:flags])
    assert_equal(100, params[:ttl])
    assert_equal('value', params[:value])
  end

  def test_parsing_append
    request = "append key 1 100\r\nvalue"
    params = RequestParser.parse(request)
    assert_equal('append', params[:command])
    assert_equal('key', params[:key])
    assert_equal('1', params[:flags])
    assert_equal(100, params[:ttl])
    assert_equal('value', params[:value])
  end

  def test_parsing_prepend
    request = "prepend key 1 100\r\nvalue"
    params = RequestParser.parse(request)
    assert_equal('prepend', params[:command])
    assert_equal('key', params[:key])
    assert_equal('1', params[:flags])
    assert_equal(100, params[:ttl])
    assert_equal('value', params[:value])
  end

  def test_parsing_cas
    request = "cas key 1 100 12345\r\nvalue"
    params = RequestParser.parse(request)
    assert_equal('cas', params[:command])
    assert_equal('key', params[:key])
    assert_equal('1', params[:flags])
    assert_equal(100, params[:ttl])
    assert_equal(12345, params[:unique_cas_token])
    assert_equal('value', params[:value])
  end

  def test_parsing_get_one_key
    request = 'get key'
    params = RequestParser.parse(request)
    assert_equal('get', params[:command])
    assert_equal(['key'], params[:keys])
  end

  def test_parsing_get_multiple_keys
    request = 'get key1 key2 key3'
    params = RequestParser.parse(request)
    assert_equal('get', params[:command])
    assert_equal(['key1', 'key2', 'key3'], params[:keys])
  end

  def test_parsing_gets_one_key
    request = 'gets key'
    params = RequestParser.parse(request)
    assert_equal('gets', params[:command])
    assert_equal(['key'], params[:keys])
  end

  def test_parsing_gets_multiple_keys
    request = 'gets key1 key2 key3'
    params = RequestParser.parse(request)
    assert_equal('gets', params[:command])
    assert_equal(['key1', 'key2', 'key3'], params[:keys])
  end
end
