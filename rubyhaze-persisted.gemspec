# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{rubyhaze-persisted}
  s.version = "0.0.2"
  s.platform = %q{jruby}

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Adrian Madrid"]
  s.date = %q{2010-09-08}
  s.description = %q{Have your in-mempry distributed JRuby objects and search them too.}
  s.email = %q{aemadrid@gmail.com}
  s.extra_rdoc_files = [
    "LICENSE",
     "README.rdoc"
  ]
  s.files = [
    "LICENSE",
     "README.rdoc",
     "Rakefile",
     "VERSION",
     "lib/rubyhaze-persisted.rb",
     "lib/rubyhaze/persisted.rb",
     "lib/rubyhaze/persisted/model.rb",
     "lib/rubyhaze/persisted/shadow_class_generator.rb",
     "test/helper.rb",
     "test/test_model.rb",
     "test/test_persisted.rb"
  ]
  s.homepage = %q{http://github.com/aemadrid/rubyhaze-persisted}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.6}
  s.summary = %q{ActiveRecord-like objects persisted with Hazelcast and RubyHaze}
  s.test_files = [
    "test/test_model.rb",
     "test/test_persisted.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rubyhaze>, ["~> 0.0.6"])
      s.add_runtime_dependency(%q<bitescript>, ["= 0.0.6"])
      s.add_runtime_dependency(%q<activesupport>, ["~> 3.0.0"])
      s.add_runtime_dependency(%q<activemodel>, ["~> 3.0.0"])
    else
      s.add_dependency(%q<rubyhaze>, ["~> 0.0.6"])
      s.add_dependency(%q<bitescript>, ["= 0.0.6"])
      s.add_dependency(%q<activesupport>, ["~> 3.0.0"])
      s.add_dependency(%q<activemodel>, ["~> 3.0.0"])
    end
  else
    s.add_dependency(%q<rubyhaze>, ["~> 0.0.6"])
    s.add_dependency(%q<bitescript>, ["= 0.0.6"])
    s.add_dependency(%q<activesupport>, ["~> 3.0.0"])
    s.add_dependency(%q<activemodel>, ["~> 3.0.0"])
  end
end

