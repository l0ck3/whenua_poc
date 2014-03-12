# TODO : Test It !
module Whenua
  module Models
    class EntityModel
      include ActiveModel::Validations

      attr_reader :entity

      delegate :id,         to: :entity
      delegate :persisted?, to: :entity

      def self.model_name
        @@entity_klass.model_name
      end

      def to_key
        @entity.to_key
      end

      def to_s
        @entity.id
      end

      def initialize(entity)
        @@entity_klass = entity.class
        @entity        = entity

        entity.attributes.each do |key, value|
          set_property(key, value)
        end
      end

      private

      def set_property(prop_name, prop_value)
        self.class.class_eval do; attr_accessor prop_name; end
        send("#{prop_name}=", prop_value)
      end

    end
  end
end
