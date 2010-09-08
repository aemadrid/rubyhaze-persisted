require(File.expand_path(File.dirname(__FILE__) + '/helper'))

class LintTest < ActiveModel::TestCase
  include ActiveModel::Lint::Tests

  class Admin
    class User
      include RubyHaze::Persisted

      attribute :name, :string
      attribute :age, :integer
      attribute :active, :boolean
      attribute :salary, :double
    end
  end

  class ImportantPerson
    include RubyHaze::Persisted

    attribute :name, :string

    before_create :notice_create_before
    after_update  :notice_update_after
    around_load   :notice_load_around
    after_destroy :notice_destroy_after

    def notice_create_before
      Notices.all << "ImportantPerson before create"
    end

    def notice_update_after
      Notices.all << "ImportantPerson after update"
    end

    def notice_load_around
      Notices.all << "ImportantPerson around load before"
      yield
      Notices.all << "ImportantPerson around load after"
    end

    def notice_destroy_after
      Notices.all << "ImportantPerson after destroy"
    end

  end

  class SimplePerson
    include RubyHaze::Persisted

    attribute :name, :string
  end

  def setup
    @model = Admin::User.new
  end

  def test_naming
    @model_name = Admin::User.model_name
    assert_equal "lint_test_admin_user", @model_name.singular
    assert_equal "lint_test_admin_users", @model_name.plural
    assert_equal "user", @model_name.element
    assert_equal "lint_test/admin/users", @model_name.collection
    assert_equal "lint_test/admin/users/user", @model_name.partial_path
  end

  def test_translation
    I18n.backend = I18n::Backend::Simple.new
    I18n.backend.store_translations 'en', :attributes => { :age => 'age default attribute' }
    assert_equal 'age default attribute', Admin::User.human_attribute_name('age')
    I18n.backend.store_translations 'en', :activemodel => {:attributes => {:foo => {:name => 'foo name attribute'} } }
    assert_equal 'foo name attribute', Foo.human_attribute_name('name')
    I18n.backend.store_translations 'en', :activemodel => {:models => {:foo => 'foo model'} }
    assert_equal 'foo model', Foo.model_name.human
  end

  def test_callbacks
    Notices.clear
    assert_equal 0, Notices.size
    important_person = ImportantPerson.create :name => "David"
    ImportantPerson.attributes
    assert_equal 1, Notices.size
    assert_equal "ImportantPerson before create", Notices.pop
    important_person.name = "David The Great"
    important_person.update
    assert_equal 1, Notices.size
    assert_equal "ImportantPerson after update", Notices.pop
    important_person.reload
    assert_equal 2, Notices.size
    assert_equal "ImportantPerson around load after", Notices.pop
    assert_equal "ImportantPerson around load before", Notices.pop
    important_person.destroy
    assert_equal 1, Notices.size
    assert_equal "ImportantPerson after destroy", Notices.pop
    assert_equal 0, Notices.size
  end

  def test_attribute_methods
    simple_person = SimplePerson.create :name => "David"
    assert_equal simple_person.name, "David"
    assert simple_person.name?
    simple_person.name = "Joseph"
    assert_equal simple_person.name, "Joseph"
  end

  def test_conversion
    simple_person = SimplePerson.create :uid => '123', :name => "David"
    assert_equal simple_person.to_model, simple_person
    assert_nil simple_person.to_key
    assert_nil simple_person.to_param
    simple_person.save
    assert_equal %w{123}, simple_person.to_key
    assert_equal '123', simple_person.to_param
  end

  def test_dirty
    uid = '456'
    names = [ "David", "Bob", "James", "Earl" ]
    SimplePerson.create :uid => uid, :name => names.first
    simple_person = SimplePerson.find uid
    assert_equal false, simple_person.changed?
    simple_person.name = names[1]
    assert simple_person.changed?
    assert simple_person.name_changed?
    assert_equal names[1], simple_person.name_was
    assert_equal names[0,2], simple_person.name_change
    exp_changes = { :name => names[0,2] }
    assert_equal exp_changes, simple_person.changes

  end
end
