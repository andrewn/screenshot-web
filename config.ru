require 'app/webservice.rb'

Sinatra::Application.default_options.merge!(
  :run => false,
  :env => :production,
  :raise_errors => true
)

log = File.new("/tmp/sinatra.log", "a+")
$stdout.reopen(log)
$stderr.reopen(log)

run Sinatra::Application
