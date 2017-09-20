require 'helper'

class TestElasticsearchTimestampCheckFilter < Test::Unit::TestCase
  def setup
    Fluent::Test.setup
  end

  def create_driver(conf='')
    Fluent::Test::Driver::Filter.new(Fluent::Plugin::ElasticsearchTimestampCheckFilter).configure(conf)
  end

  def test_added_timestamp
    d = create_driver
    d.run(default_tag: 'test') do
      d.feed({'test' => 'notime'})
    end
    filtered = d.filtered.map {|e| e.last}.first
    assert_true(filtered.key?("@timestamp"))
    assert_true(filtered.key?("fluent_added_timestamp"))
  end

  data('@timestamp'       => '@timestamp',
       'timestamp'        => 'timestamp',
       'time'             => 'time',
       'syslog_timestamp' => 'syslog_timestamp')
  def test_timestamp_with_normal(data)
    timekey = data
    d = create_driver
    timestamp = '2017-09-19T14:40:08.321+0900'
    d.run(default_tag: 'test') do
      d.feed({'test' => 'notime'}.merge(timekey => timestamp))
    end
    filtered = d.filtered.map{|e| e.last}.first
    assert_true(filtered.key?("@timestamp"))
    assert_true(filtered.key?("fluent_converted_timestamp"))
    assert_equal(timestamp, filtered["fluent_converted_timestamp"])
  end

  data('@timestamp'       => '@timestamp',
       'timestamp'        => 'timestamp',
       'time'             => 'time',
       'syslog_timestamp' => 'syslog_timestamp')
  def test_timestamp_with_digit(data)
    timekey = data
    d = create_driver
    timestamp = '1505800348899'
    d.run(default_tag: 'test') do
      d.feed({'test' => 'notime'}.merge(timekey => timestamp))
    end
    filtered = d.filtered.map{|e| e.last}.first
    num = timestamp.to_f
    formatted_time = Time.at(
      num / (10 ** ((Math.log10(num).to_i + 1) - 10))
    ).strftime('%Y-%m-%dT%H:%M:%S.%L%z')
    assert_true(filtered.key?("@timestamp"))
    assert_true(filtered.key?("fluent_converted_timestamp"))
    assert_equal(formatted_time, filtered["fluent_converted_timestamp"])
  end

end
