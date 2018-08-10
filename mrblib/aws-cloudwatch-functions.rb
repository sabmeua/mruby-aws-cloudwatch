module AWS::CloudWatch

  module Functions

    def list_metrics()
      params = {
        :Action => 'ListMetrics',
        :Version => AWS::CloudWatch::API_VERSION_LATEST
      }
      request('POST', params)
    end

  end

end

