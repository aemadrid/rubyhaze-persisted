gem "bitescript", "0.0.6"
require 'bitescript'

module RubyHaze
  module Persisted
    module Shadow

      module Classes
      end

      class Generator

        class << self

          def get(name, attributes)
            safe_name = name.gsub '::', '__'
            RubyHaze::Persisted::Shadow::Classes.const_defined?(safe_name) ?
              RubyHaze::Persisted::Shadow::Classes.const_get(safe_name) :
              generate(name, attributes)
          end

          def attribute_load_types
            {
              :string  => :aload,
              :int     => :iload,
              :boolean => :iload,
              :double  => :dload,
            }
          end

          def template(name, attributes)
            str = []
            packages = %w{org rubyhaze persisted shadow classes}
            names = name.split '::'
            name = names.pop
            packages += names
            str << "package '#{packages.join('.')}' do"
            str << %{  public_class "#{name}", object, Java::JavaIo::Serializable do}
            attributes.each do |attr_name, type, options|
              str << %{    public_field :#{attr_name}, send(:#{type})}
            end
            str << %{    public_constructor [], #{attributes.map { |ary| ary[1].to_s }.join(', ')} do}
            str << %{      aload 0}
            str << %{      invokespecial object, "<init>", [void]}
            index = 1
            attributes.each do |attr_name, type, options|
              str << %{      aload 0}
              load_type = attribute_load_types[type]
              raise "Unknown load type for attribute [#{attr_name}] on class [#{name}]" unless load_type
              str << %{      #{load_type} #{index}}
              index += 1
              str << %{      putfield this, :#{attr_name}, send(:#{type})}
            end
            str << %{      returnvoid}
            str << %{    end}
            str << %{  end}
            str << %{end}
            str.join("\n")
          end

          def generate(name, attributes)
            tmp_path = (ENV['RUBYHAZE_PERSISTED_TMP_PATH'] || File.join(Dir.pwd, 'tmp'))
            builder = BiteScript::FileBuilder.new name + '.class'
            str = template name, attributes
            if $DEBUG
              FileUtils.mkdir_p tmp_path
              filename = File.join tmp_path, name + '.bc'
              puts ">> Saving bitescript [#{filename}]..."
              File.open(filename, 'w') { |file| file.write str }
            end
            builder.instance_eval str, __FILE__, __LINE__
            safe_name = name.gsub '::', '__'
            builder.generate do |builder_filename, class_builder|
              bytes = class_builder.generate
              klass = JRuby.runtime.jruby_class_loader.define_class builder_filename[0..-7].gsub('/', '.'), bytes.to_java_bytes
              if $DEBUG
                filename = File.join tmp_path, builder_filename
                FileUtils.mkdir_p File.dirname(filename)
                puts ">> Saving class [#{filename}]..."
                File.open(filename, 'w') { |file| file.write class_builder.generate }
              end
              RubyHaze::Persisted::Shadow::Classes.const_set safe_name, JavaUtilities.get_proxy_class(klass.name)
            end
            RubyHaze::Persisted::Shadow::Classes.const_get safe_name
          end

        end
      end
    end
  end
end
