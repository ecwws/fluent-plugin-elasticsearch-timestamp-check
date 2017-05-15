require 'fluent/plugin/filter'

module Fluent::Plugin
  class ElasticsearchTimestampCheckFilter < Filter
    Fluent::Plugin.register_filter('elasticsearch_timestamp_check', self)

    def configure(conf)
      super
      require 'date'
    end

    def start
      super
    end

    def shutdown
      super
    end

    def filter(tag, time, record)
      timestamps = [ record['@timestamp'], record['timestamp'], record['time'] ]
      valid = false
      timestamps.each do |timestamp|
        begin
          if timestamp then
            DateTime.parse(timestamp)
            valid = timestamp
            break
          end
        rescue ArgumentError
          next
        end
      end

      if valid
        record['@timestamp'] =
          DateTime.parse(valid).strftime('%Y-%m-%dT%H:%M:%S.%L%z')
        record['fluent_converted_timestamp'] =
          DateTime.parse(valid).strftime('%Y-%m-%dT%H:%M:%S.%L%z')
        $log.debug("Timestamp parsed: #{record['@timestamp']}")
      else
        record['@timestamp'] = Time.now.strftime('%Y-%m-%dT%H:%M:%S.%L%z')
        record['fluent_added_timestamp'] =
          Time.now.strftime('%Y-%m-%dT%H:%M:%S.%L%z')
        $log.debug("Timestamp added: #{record['@timestamp']}")
      end
      record
    end
  end
end

