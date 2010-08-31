require 'bitescript'

module RubyHaze
  module Persisted
    module ShadowClassGenerator

      def self.get(name, attributes)
        RubyHaze::Persisted.const_defined?(name) ?
          RubyHaze::Persisted.const_get(name) :
          generate(name, attributes)
      end

      def self.attribute_load_types
        {
          :string  => :aload,
          :int     => :iload,
          :boolean => :iload,
          :double  => :dload,
        }
      end

      def self.generate(name, attributes)
        tmp_path = (ENV['RUBYHAZE_PERSISTED_TMP_PATH'] || File.join(Dir.pwd, 'tmp'))
        builder = BiteScript::FileBuilder.new name + '.class'
        class_dsl = []
        class_dsl << %{public_class "#{name}", object, Java::JavaIo::Serializable do}
        attributes.each do |attr_name, type, options|
          class_dsl << %{  public_field :#{attr_name}, send(:#{type})}
        end
        class_dsl << %{  public_constructor [], #{attributes.map { |ary| ary[1].to_s }.join(', ')} do}
        class_dsl << %{    aload 0}
        class_dsl << %{    invokespecial object, "<init>", [void]}
        index = 1
        attributes.each do |attr_name, type, options|
          class_dsl << %{    aload 0}
          class_dsl << %{    #{attribute_load_types[type]} #{index}}
          index += 1
          class_dsl << %{    putfield this, :#{attr_name}, send(:#{type})}
        end
        class_dsl << %{    returnvoid}
        class_dsl << %{  end}
        class_dsl << %{end}
        class_dsl = class_dsl.join("\n")
        if $DEBUG
          FileUtils.mkdir_p tmp_path
          filename = File.join tmp_path, name + '.bc'
          File.open(filename, 'w') { |file| file.write class_dsl }
        end
        builder.instance_eval class_dsl, __FILE__, __LINE__
        builder.generate do |builder_filename, class_builder|
          bytes = class_builder.generate
          klass = JRuby.runtime.jruby_class_loader.define_class name, bytes.to_java_bytes
          if $DEBUG
            filename = File.join tmp_path, builder_filename
            File.open(filename, 'w') { |file| file.write class_builder.generate }
          end
          RubyHaze::Persisted.const_set name, JavaUtilities.get_proxy_class(klass.name)
        end
        RubyHaze::Persisted.const_get name
      end

    end
  end
end