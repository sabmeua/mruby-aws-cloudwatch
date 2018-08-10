module AWS

  class SimpleHttpExt < SimpleHttp
    def create_request_header(method, req)
      super(method, req).sub(/Connection: close\n/, '')
    end
  end

  class CloudWatch
    SERVICE = 'monitoring'
    API_VERSION_LATEST = '2010-08-01'

    def initialize(access_key, secret_key, region = nil, endpoint = nil)
      @access_key = access_key || ENV['AWS_ACCESS_KEY_ID']
      @secret_key = secret_key || ENV['AWS_SECRET_ACCESS_KEY']
      @region = region || ENV["AWS_DEFAULT_REGION"] || 'us-east-1'
      @endpoint = HTTP::Parser.new.parse_url("https://#{SERVICE}.#{@region}.amazonaws.com")
      @http = SimpleHttpExt.new(@endpoint.schema, @endpoint.host, @endpoint.port)
    end

    def list_metrics()
      params = {
        :Action => 'ListMetrics',
        :Version => API_VERSION_LATEST
      }
      request('POST', params)
    end

    def request(method = 'GET', params = {}, header = {})
      method = method.upcase
      path = '/'
      now = Time.now.utc
      timestamp = now.strftime("%Y%m%dT%H%M%SZ")
      date = now.strftime('%Y%m%d')
      payload = ''
      query = nil

      header['Host'] = @endpoint.host
      header['X-Amz-Date'] = timestamp
      header['Accept'] = 'application/json'
      if method == 'POST'
        header['Content-Type'] = 'application/x-www-form-urlencoded; charset=utf-8'
        payload = params.map{|k,v| "#{k}=#{v}"}.join('&')
        header['Content-Length'] = payload.bytesize
      else
        query = params.map{|k,v| "#{k}=#{v}"}.join('&')
      end

      canonical = "#{method}\n#{path}\n#{query}\n"
      header.keys.sort.each do |k|
        canonical += "#{k.downcase}:#{header[k].to_s.strip}\n"
      end
      signed_header = header.keys.sort.join(';').downcase
      canonical += "\n#{signed_header}\n#{Digest::SHA256::hexdigest(payload)}"

      #puts "\n\n"
      #puts canonical
      #puts "\n\n"

      algo = 'AWS4-HMAC-SHA256'
      scope = "#{date}/#{@region}/#{SERVICE}/aws4_request"
      hash = Digest::SHA256.hexdigest(canonical)
      str_to_sign = "#{algo}\n#{timestamp}\n#{scope}\n#{hash}"

      sign_key = Digest::HMAC.digest('aws4_request',
        Digest::HMAC.digest(SERVICE,
          Digest::HMAC.digest(@region,
            Digest::HMAC.digest(date,
              "AWS4#{@secret_key}",Digest::SHA256),
            Digest::SHA256),
          Digest::SHA256),
        Digest::SHA256)
      
      sign = Digest::HMAC.hexdigest(str_to_sign, sign_key, Digest::SHA256)

      header['Authorization'] = "#{algo} Credential=#{@access_key}/#{scope}"
      header['Authorization'] += ",SignedHeaders=#{signed_header}"
      header['Authorization'] += ",Signature=#{sign}"
      if method == 'POST'
        header['Body'] = payload
      end

      #puts "\n\nstr to sign\n#{str_to_sign}\n\n"
      #puts "\n\nsign key\n#{sign_key}\n\n"
      #puts "\n\nauthorization\n#{header['Authorization']}\n\n"

      path += "?#{query}" if query
      @http.request method, path, header
    end
  end
end

