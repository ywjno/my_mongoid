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

    module ClassMethods
      def is_mongoid_model?
        true
      end
    end
  end
end
