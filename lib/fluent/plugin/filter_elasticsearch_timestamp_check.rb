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
          # all digit entry would be treated as epoch seconds or epoch millis
          if !!(timestamp =~ /\A[-+]?\d+\z/)
            num = timestamp.to_f
            # epoch second or epoch millis should be either 10 or 13 digits
            # other length should be considered invalid (until the next digit
            # rollover at 2286-11-20  17:46:40 Z
            next unless [10, 13].include?(Math.log10(num).to_i + 1)
            record['@timestamp'] = record['fluent_converted_timestamp'] =
              Time.at(
                num / (10 ** ((Math.log10(num).to_i + 1) - 10))
              ).strftime('%Y-%m-%dT%H:%M:%S.%L%z')
            break
          end

          # normal timestamp string processing
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

