module AWS; end

module AWS::CloudWatch

  module MetricDataQuery

    module Expose
      def build(query)
        result = {}
        serialize query, "MetricDataQueries", result
      end

      def serialize(elm, str, buff)
        i = 0
        elm.each do |k,v|
          if v.nil?
            v = k
            i = i + 1
            k = "member.#{i}"
          end
          if v.kind_of?(Enumerable)
            buff.merge(serialize v, "#{str}.#{k}", buff)
          else
            buff["#{str}.#{k}"] = v
          end
        end
        buff
      end
    end

    extend Expose

  end

end

