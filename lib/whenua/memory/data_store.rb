require 'active_support/hash_with_indifferent_access'

# TODO : Indexes implementation is a bit simple. Could be enhanced to mimic Couchbase behavior
module Whenua
  module Memory
    class DataStore
      attr_reader :data

      def initialize(params={})
        @data = ActiveSupport::HashWithIndifferentAccess.new
      end

      def delete(key)
        @data.delete(key)
      end


      def fetch(index, document=nil, params={})
        raise IndexMissingError.new unless self.private_methods.include?(index)

        return self.send(index)
      end

      # TODO : Update it + Test to manage multiple ids
      def get(key)
        if @data[key].present?
          {
            key: key,
            data: @data[key]
          }
        end
      end

      def save(data)
        key      = data[:key]
        document = data[:value]

        if key.nil?
          key = _generate_id
        end

        @data[key] = ActiveSupport::HashWithIndifferentAccess.new(document)

        key
      end

      def client
        self
      end


    private

      def _generate_id
        SecureRandom.uuid
      end

    end
  end
end
