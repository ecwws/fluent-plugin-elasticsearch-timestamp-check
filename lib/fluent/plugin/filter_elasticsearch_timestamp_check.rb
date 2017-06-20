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
      %w{@timestamp timestamp time syslog_timestamp}.map do |field|
        record[field]
      end.compact.each do |timestamp|
        begin
          record['@timestamp'] = record['fluent_converted_timestamp'] =
            DateTime.parse(timestamp).strftime('%Y-%m-%dT%H:%M:%S.%L%z')
          $log.debug("Timestamp parsed: #{record['@timestamp']}")
          break
        rescue ArgumentError
        end
      end

      unless record['fluent_converted_timestamp']
        record['@timestamp'] = record['fluent_added_timestamp'] =
          Time.now.strftime('%Y-%m-%dT%H:%M:%S.%L%z')
        $log.debug("Timestamp added: #{record['@timestamp']}")
      end

      record
    end
  end
end

