MRuby::Gem::Specification.new('mruby-aws-cloudwatch') do |spec|
  spec.license = 'MIT'
  spec.authors = 'sabmeua'

  spec.add_dependency 'mruby-http'
  spec.add_dependency 'mruby-uv'
  spec.add_dependency 'mruby-digest'
  spec.add_dependency 'mruby-pack'
  spec.add_dependency 'mruby-simplehttp'
  spec.add_dependency 'mruby-string-ext'
  spec.add_dependency 'mruby-time-strftime'
  spec.add_dependency 'mruby-env'
  spec.add_dependency 'mruby-onig-regexp'
end

