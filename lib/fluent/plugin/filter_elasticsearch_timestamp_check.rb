require 'fluent/plugin/filter'

module Fluent::Plugin
  class ElasticsearchTimestampCheckFilter < Filter
    attr_reader :timestamp_digits

    Fluent::Plugin.register_filter('elasticsearch_timestamp_check', self)

    config_param :subsecond_precision, :integer, default: 3

    def configure(conf)
      super
      require 'date'
      raise Fluent::ConfigError, "specify 1 or bigger number." if subsecond_precision < 1
      @strftime_format = "%Y-%m-%dT%H:%M:%S.%#{@subsecond_precision}N%z".freeze
      @timestamp_digits = configure_digits
    end

    def configure_digits
      subepoch_precision = 10 + @subsecond_precision
      timestamp_digits = [10, 13]
      timestamp_digits << subepoch_precision
      timestamp_digits.uniq!
      timestamp_digits
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
            # By default, epoch second or epoch millis should be either 10 or 13 digits
            # other length should be considered invalid (until the next digit
            # rollover at 2286-11-20  17:46:40 Z
            # For user-defined precision also should handle here.
            next unless @timestamp_digits.include?(Math.log10(num).to_i + 1)
            record['@timestamp'] = record['fluent_converted_timestamp'] =
              Time.at(
                num / (10 ** ((Math.log10(num).to_i + 1) - 10))
              ).strftime(@strftime_format)
            break
          end

          # normal timestamp string processing
          record['@timestamp'] = record['fluent_converted_timestamp'] =
            DateTime.parse(timestamp).strftime(@strftime_format)
          $log.debug("Timestamp parsed: #{record['@timestamp']}")
          break
        rescue ArgumentError
        end
      end

      unless record['fluent_converted_timestamp']
        record['@timestamp'] = record['fluent_added_timestamp'] =
          Time.at(time.is_a?(Fluent::EventTime) ? time.to_int : time).strftime(@strftime_format)
        $log.debug("Timestamp added: #{record['@timestamp']}")
      end

      record
    end
  end
end

