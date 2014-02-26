require "my_mongoid/version"

module MyMongoid
  def self.models
    @models ||= []
  end

  class Field
    attr_reader :name, :options

    def initialize(name, options)
      @name = name.to_s
      @options = options
    end
  end

  module Document
    def self.included(base)
      base.extend(ClassMethods)
      base.field('_id', :as => :id)
      MyMongoid.models << base
    end

    attr_reader :attributes, :new_record

    def initialize(attrs={})
      @attributes ||= {}
      raise ArgumentError unless attrs.is_a? Hash
      process_attributes(attrs)
      @new_record = true
    end

    def read_attribute(attr)
      @attributes[attr.to_s]
    end

    def write_attribute(attr, value)
      @attributes[attr.to_s] = value
    end

    def new_record?
      @new_record
    end

    def process_attributes(attrs)
      attrs.each do |key, value|
        key = key.to_s
        raise UnknownAttributeError unless self.class.instance_methods.map { |i| i.to_s }.include?("#{key}=")
        self.send("#{key}=", value)
      end
    end

    alias :attributes= :process_attributes

    module ClassMethods
      def is_mongoid_model?
        true
      end

      def field(field_name, options = {})
        field_name = field_name.to_s
        raise DuplicateFieldError if fields.key?(field_name)
        fields[field_name] = MyMongoid::Field.new(field_name, options)
        class_eval %Q{
          def #{field_name}
            self.read_attribute('#{field_name}')
          end

          def #{field_name}=(value)
            self.write_attribute('#{field_name}', value)
          end

          if options
            alias_method('#{options[:as]}', '#{field_name}')
            alias_method('#{options[:as]}=', '#{field_name}=')
          end
        }
      end

      def fields
        @fields ||= {}
      end
    end
  end

  class DuplicateFieldError < RuntimeError;end
  class UnknownAttributeError < RuntimeError;end
end
