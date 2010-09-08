gem "activesupport", "3.0.0"
require "active_support/core_ext/module/attr_accessor_with_default"
require "active_support/core_ext/object/blank"
require "active_support/concern"
require "active_support/callbacks"

gem "activemodel", "3.0.0"
require "active_model"

module RubyHaze

  module Persisted
    class Register
      class << self
        def classes
          @classes ||= []
        end

        def add(base)
          return false if classes.include? base.name
          classes << base.name
          true
        end
      end
    end

   def self.included(base)
     return unless RubyHaze::Persisted::Register.add(base)

     base.send :extend, ClassMethods
     base.send :extend, ActiveModel::Naming
     base.send :extend, ActiveModel::Translation
     base.send :extend, ActiveModel::Callbacks

     base.send :include, ActiveModel::AttributeMethods
     base.send :include, ActiveModel::Conversion
     base.send :include, ActiveModel::Dirty
     base.send :include, ActiveModel::Serialization
     base.send :include, ActiveModel::Serializers::JSON
     base.send :include, ActiveModel::Serializers::Xml
     base.send :include, ActiveModel::Validations
     base.send :include, InstanceMethods

     base.attribute_method_suffix '', '=', '?'
     base.define_model_callbacks :create, :update, :load, :destroy
   end

    module InstanceMethods

      def initialize(options = {})
        options.each { |name, value| send "#{name}=", value }
        @callbacks = []
        @new_record = true
        @destroyed = false
      end

      def new_record?
        @new_record
      end

      def persisted?
        !(new_record? || destroyed?)
      end

      def destroyed?
        @destroyed
      end

      def attribute(key)
        instance_variable_get("@#{key}")
      end

      def attribute=(key, value)
        send("#{key}_will_change!") unless value == attribute(key)
        instance_variable_set("@#{key}", value)
      end

      def attribute?(key)
        instance_variable_get("@#{key}").present?
      end

      def attribute_names
        self.class.attribute_names
      end

      def attribute_types
        self.class.attribute_types
      end

      def attribute_options
        self.class.attribute_options
      end

      def attributes
        attrs = {}
        attribute_names.each { |name| attrs[name.to_s] = attribute(name) }
        attrs
      end

      def values
        attribute_names.map { |name| attribute(name) }
      end

      def to_ary
        attribute_names.map { |name| [name.to_s, instance_variable_get("@#{name}")] }.unshift ['class', self.class.name]
      end

      def ==(other)
        return false unless other.respond_to? :to_ary
        to_ary == other.to_ary
      end

      def shadow_object
        self.class.map_java_class.new *values
      end

      def load_shadow_object(shadow)
        attribute_names.each do |name|
          send "attribute=", name, shadow.send(name)
        end
        self
      end

      def save
        create_or_update
      end

      def save!
        create_or_update || raise("Not saved")
      end

      def create_or_update
        result = new_record? ? create : update
        result != false
      end

      def create
        _run_create_callbacks do
          @uid ||= RubyHaze.random_uuid
          self.class.map[uid] = shadow_object
          @previously_changed = changes
          @changed_attributes.clear
          @new_record = false
          uid
        end
      end

      def update
        _run_update_callbacks do
          raise "Missing uid" unless uid?
          self.class.map[uid] = shadow_object
          @previously_changed = changes
          @changed_attributes.clear
          true
        end
      end

      def load
        _run_load_callbacks do
          raise "Missing uid for load" if uid.blank?
          found = self.class.map[uid]
          raise "Record not found" unless found
          load_shadow_object(found)
          @changed_attributes.clear
          @new_record = false
          self
        end
      end
      alias :reload :load
      alias :reset  :load

      def destroy
        _run_destroy_callbacks do
          if persisted?
            self.class.map.remove uid
          end
          @destroyed = true
          freeze
        end
      end
      alias :delete :destroy

      def to_s
        "<#{self.class.name}:#{object_id} #{to_ary[1..-1].map { |k, v| "#{k}=#{v}" }.join(" ")} >"
      end

      alias :inspect :to_s

      def to_key
        persisted? ? [uid] : nil
      end

    end

    module ClassMethods

      def create(options = {})
        obj = new options
        obj.save
        obj
      end

      def map_java_class
        @java_class ||= RubyHaze::Persisted::Shadow::Generator.get name, attributes
      end

      def map
        @map ||= RubyHaze::Map.new "RubyHaze::Persisted #{name}"
      end

      def attributes
        @attributes ||= [[:uid, :string, {}]]
      end

      def attribute_names()
        attributes.map { |ary| ary[0] }
      end

      def attribute_types()
        attributes.map { |ary| ary[1] }
      end

      def attribute_options()
        attributes.map { |ary| ary[2] }
      end

      def attribute(name, type, options = {})
        raise "Attribute [#{name}] already defined" if attribute_names.include?(name)
        @attributes << [name, type, options]
        @attribute_methods_generated = false
        define_attribute_methods [ name ]
        self
      end

      def find(predicate)
        map.values(predicate).map { |shadow| new.load_shadow_object shadow }
      end

      def [](*args)
        options = args.extract_options!
        options[:uid] = args.first if RubyHaze.valid_uuid?(args.first)
        find(options).first
      end

      def find_uids(predicate)
        map.keys(predicate)
      end

    end

  end
end
