require "my_mongoid/version"

module MyMongoid
  def self.models
    @models ||= []
  end
  module Document
    def self.included(base)
      base.extend(ClassMethods)
      MyMongoid.models << base
    end

    attr_reader :attributes, :new_record

    def initialize(options={})
      raise ArgumentError unless options.is_a? Hash
      @attributes = options
      @new_record = true
      self
    end

    def read_attribute(key)
      @attributes[key]
    end

    def write_attribute(key, value)
      @attributes[key] = value
    end

    def new_record?
      @new_record
    end

    module ClassMethods
      def is_mongoid_model?
        true
      end
    end
  end
end
