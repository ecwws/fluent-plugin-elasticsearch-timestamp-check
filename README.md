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

* If *@timestamp* field already exists, it will ensure the format is correct
  by parse and convert to format '%Y-%m-%dT%H:%M:%S%z'. **As of version 0.2.4, it
  will support epoch second / epoch millis format as a valid timestamp value. If
  such value is detected, it will be converted to iso8601 format for easier
  consumption of elasticsearch when dynamic mapping is used.**

* If a field named *timestamp* or *time* or *syslog_timestamp* exists, it will
  parse that field and conver it to format '%Y-%m-%dT%H:%M:%S%z' then store it
  in *@timestamp* field.

* If none of the above field exists, it will insert current time in
  '%Y-%m-%dT%H:%M:%S%z' format as the *@timestamp* field.

## Usage

```
<filter **>
  type elasticsearch_timestamp_check
</filter>
```
