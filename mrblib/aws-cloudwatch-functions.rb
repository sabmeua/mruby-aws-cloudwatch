module AWS; end

module AWS::CloudWatch

  module Functions
    ISO8601_UTC = '%Y-%m-%dT%H:%M:%SZ'

    def list_metrics()
      params = {
        :Action => 'ListMetrics',
        :Version => AWS::CloudWatch::API_VERSION_LATEST
      }
      request('POST', params)
    end

    def get_metric_data(start_time, end_time, metric_data_query)
      start_time = Time.at(start_time) if !start_time.instance_of? Time
      end_time = Time.at(end_time) if !end_time.instance_of? Time
      params = {
        :Action => 'GetMetricData',
        :Version => AWS::CloudWatch::API_VERSION_LATEST,
        :StartTime => start_time.utc.strftime(ISO8601_UTC),
        :EndTime => end_time.utc.strftime(ISO8601_UTC)
      }
      params.merge!(AWS::CloudWatch::MetricDataQuery::build(metric_data_query))
      request('POST', params)
    end

    def get_metric_statistics(start_time, end_time,
        name_space, metric_name, period, statistics = nil, dimensions = nil)
      start_time = Time.at(start_time) if !start_time.instance_of? Time
      end_time = Time.at(end_time) if !end_time.instance_of? Time
      params = {
        :Action => 'GetMetricStatistics',
        :Version => AWS::CloudWatch::API_VERSION_LATEST,
        :StartTime => start_time.utc.strftime(ISO8601_UTC),
        :EndTime => end_time.utc.strftime(ISO8601_UTC),
        :Namespace => name_space,
        :MetricName => metric_name,
        :Period => period
      }
      if statistics
        statistics = statistics.split ' ' if statistics.kind_of? String
        params.merge!(AWS::CloudWatch::MetricDataQuery::serialize(statistics, 'Statistics', {}))
      end
      if dimensions
        if dimensions.kind_of? String
          dimensions = dimensions.split(',').map{|v| v.split '='}.to_h
        end
        params.merge!(AWS::CloudWatch::MetricDataQuery::serialize([dimensions], 'Dimensions', {}))
      end
      request('POST', params)
    end

  end

end

