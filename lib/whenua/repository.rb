require 'active_support/core_ext/object'
require 'active_support/core_ext/hash/indifferent_access'

module Whenua
  module Repository
    extend ActiveSupport::Concern

    included do
      self.class.send(:cattr_accessor, :indexes)
    end

    def initialize(data_store=nil)
      @data_store = data_store
    end

    def data_store
      @data_store
    end

    def data_store=(data_store)
      @data_store = data_store
    end

    def delete(entity)
      data_store.delete(entity.id)
      true
    end


    def find_by_id(id)
      if hash = data_store.get(id)
        result = _deserialize(hash[:key], hash[:data])
      else
        result = false
      end

      result
    end

    # TODO : Test it !
    def find_by_ids(ids)
      rows    = data_store.get(ids)
      results = []
      rows    = [] << rows unless rows.instance_of?(Array)

      rows.each do |row|
        results << _deserialize(row[:key], row[:data])
      end

      results
    end

    def save(entity)
      entity.touch
      save_without_timestamps(entity)
    end

    def save_without_timestamps(entity)
      hash = {
        value:  _serialize(entity)
      }

      if entity.id
        hash[:key] = entity.id
        data_store.save(hash)
      else
        entity.instance_variable_set("@id", data_store.save(hash))
      end

      entity
    end

    def entity_class
      self.class.name.to_s.gsub("Repository", "").constantize
    end

    def deserialize(attributes)
      instance = entity_class.new(attributes)
      instance.instance_variable_set(:@id, attributes[:id])
      instance.instance_variable_set(:@created_at, attributes[:created_at])
      instance.instance_variable_set(:@updated_at, attributes[:updated_at])
      instance
    end

    def serialize(entity)
      HashWithIndifferentAccess.new(entity.instance_values)
    end

    private

    def _deserialize(id, data)
      attributes      = data.with_indifferent_access
      attributes[:id] = id

      deserialize(attributes)
    end

    def _serialize(entity)
      serialized_entity        = serialize(entity).reject { |key, val| val.nil? }
      serialized_entity[:type] = entity.type
      serialized_entity
    end

    def _build_index_method(index_name)

    end

    module ClassMethods
      def index(name)
        self.send(:define_method, name) do |params={}|
          rows = data_store.fetch(name, entity_class.to_s.underscore, params)
          rows.map! do |row|
            if row[:value].respond_to? :to_hash
              row = _deserialize(row[:id], row[:value])
            else
              row = row.value
            end
          end
        end
      end
    end
  end
end
