unless defined?(HELPER_LOADED)

  require 'test/unit'
  require 'forwardable'

  require File.expand_path(File.dirname(__FILE__) + '/../lib/rubyhaze/persisted')

  class Notices
    class << self
      extend Forwardable
      def all
        @all ||= []
      end
      def_delegators :all, :size, :<<, :first, :last, :pop, :clear, :map
    end
  end

  class Foo
    include RubyHaze::Persisted
    attribute :name, :string
    attribute :age, :int
  end

  module Sub
    class Foo
      include RubyHaze::Persisted
      attribute :name, :string
    end
  end

  # Start a new hazelcast cluster
  RubyHaze.init :group => { :username => "test_persisted", :password => "test_persisted" }

  HELPER_LOADED = true

  class Test::Unit::TestCase
  end

end
