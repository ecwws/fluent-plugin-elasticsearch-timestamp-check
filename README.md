# fluent-plugin-elasticsearch-timestamp-check
Fluent plugin to ensure @timestamp is in correct format for elasticsearch

## Install

```bash
gem install fluent-plugin-elasticsearch-timestamp-check
```

## Description

The purpose of this filter is to make sure the @timestamp field exists in the
record which is necessary for the record to be indexed properly by
elasticsearch.

* If `@timestamp` field already exists, it will ensure the format is correct
  by parse and convert to format '%Y-%m-%dT%H:%M:%S%z'. **As of version 0.2.4, it
  will support epoch second / epoch millis format as a valid timestamp value. If
  such value is detected, it will be converted to iso8601 format for easier
  consumption of elasticsearch when dynamic mapping is used.**

* By default, it will check whether fields named `timestamp`, `time`, or
  `syslog_timestamp` exists, if so it will parse that field and conver it to
  format '%Y-%m-%dT%H:%M:%S.%L%z' then store it in `@timestamp` field. In
  addition, a field `fluent_converted_timestamp` is added to the object with
  the same value.

* (>=0.3.0) the list of fields can be overriden by setting the
  `timestamp_fields` parameter. It accepts a list of strings, the default is set
  to: `['@timestamp', 'timestamp', 'time', 'syslog_timestamp']`

* If none of the above field exists, it will insert current event time in
  '%Y-%m-%dT%H:%M:%S.%L%z' format as the `@timestamp` field. A field
  `fluent_added_timestamp` is added to the object with same value.

## (>=0.2.6) Subsecond Precision

`subsecond_precision` controls the subsecond precision during the conversion.
Default value is set to `3` (millisecond).

Other `subsecond_precision` sample values are:

* `6` (microsecond)
* `9` (nanosecond)
* `12` (picosecond)

and more high precision is also supported.

## Usage

```
<filter **>
  type elasticsearch_timestamp_check
  subsecond_precision 3
</filter>
```
