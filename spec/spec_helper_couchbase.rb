require 'rubygems'
require 'bundler/setup'

require 'couchbase'
require 'whenua'

RSpec.configure do |config|

  config.before(:all) do
    Couchbase.new(
      host: 'localhost',
      port: 8091,
      bucket: 'whenua-test'
    ).flush
  end

end
