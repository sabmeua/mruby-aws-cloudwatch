# mruby-aws-cloudwatch

## Example

```:ruby
AWS_API_KEY = 'API_KEY_STRING'
AWS_API_SECRET = 'API_SECRET_STRING'

client = AWS::CloudWatch::Client.new(AWS_API_KEY, AWS_API_SECRET, 'ap-northeast-1')

p client.list_metrics

p JSON::parse client.get_metric_statistics(Time.now - 3600, Time.now, 'AWS/EC2', 'CPUUtilization', 300, 'Average').body
```
