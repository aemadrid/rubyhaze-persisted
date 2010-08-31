$:.unshift File.expand_path(File.join(File.dirname(__FILE__), 'persisted'))
require 'shadow_class_generator'
require 'model'

class D
  include RubyHaze::Persisted
  attribute :name, :string
  attribute :age, :int 


  validates_presence_of :name
end