begin
  gem "rubyhaze", "~> 0.0.6"
rescue NoMethodError
  require 'rubygems'
  gem "rubyhaze", "~> 0.0.6"
ensure
  require "rubyhaze"
end

$:.unshift File.expand_path(File.join(File.dirname(__FILE__), 'persisted'))

require 'shadow_class_generator'
require 'model'
