require 'test/unit'
require 'forwardable'

require File.expand_path(File.dirname(__FILE__) + '/../lib/rubyhaze/persisted')

class Test::Unit::TestCase
end

# Start a new hazelcast cluster
RubyHaze.init :group => { :username => "test_persisted", :password => "test_persisted" }

