require "my_mongoid/version"

module MyMongoid
  def self.models
    @models ||= []
  end

  class Field
    attr_accessor :name

    def initialize(name)
      @name = name.to_s
    end
  end

  module Document
    def self.included(base)
      base.extend(ClassMethods)
      base.field('_id')
      MyMongoid.models << base
    end

    attr_reader :attributes, :new_record

    def initialize(options={})
      raise ArgumentError unless options.is_a? Hash
      @attributes = options
      @new_record = true
      self
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

    module ClassMethods
      def is_mongoid_model?
        true
      end

      def field(field_name)
        field_name = field_name.to_s
        raise DuplicateFieldError if fields.key?(field_name)
        fields[field_name] = MyMongoid::Field.new(field_name)
        class_eval %Q{
          def #{field_name}
            self.read_attribute('#{field_name}')
          end

          def #{field_name}=(value)
            self.write_attribute('#{field_name}', value)
          end
        }
      end

      def fields
        @fields ||= {}
      end
    end
  end

  class DuplicateFieldError < RuntimeError
  end
end
