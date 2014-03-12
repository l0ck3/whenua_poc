require 'active_support'
require 'active_model'
require 'virtus'

module Whenua
  module Entity
    include Virtus
    extend ActiveSupport::Concern
    include ActiveModel::Conversion
    extend ActiveModel::Naming

    included do
      attr_reader :id
    end

    def created_at
      Time.parse @created_at.to_s
    end

    def updated_at
      Time.parse @updated_at.to_s
    end

    def persisted?
      id.present?
    end

    def touch
      now = Time.now.utc
      @created_at = now if @created_at.nil?
      @updated_at = now
    end

    def type
      self.class.name.underscore
    end

    def update_attribute(attribute, value)
      self[attribute] = value
    end

    def update_attributes(attributes)
      self.attributes = attributes
    end

    def ==(other)
      self.type == other.type && self.id == other.id
    end

  end
end
