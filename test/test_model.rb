require File.expand_path(File.dirname(__FILE__) + '/helper')

class LintTest < ActiveModel::TestCase
  include ActiveModel::Lint::Tests

  class PersistedTestModel
    include RubyHaze::Persisted
    attribute :name, :string
  end

  def setup
    @model = PersistedTestModel.new
  end
end