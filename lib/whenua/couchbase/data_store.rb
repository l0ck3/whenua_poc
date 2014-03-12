require 'couchbase'

module Whenua
  module Couchbase
    class DataStore

      def initialize(params)
        @host   = params[:host]
        @port   = params[:port]
        @bucket = params[:bucket]
      end

      def client
        @client ||= ::Couchbase.new(
          host: @host,
          port: @port,
          bucket: @bucket
        )
      end

      def delete(key)
        client.delete(key)
      end

      def fetch(index, document, params={})
        default_params = { limit: 100 }
        begin
          # TODO : Inverse the behavior and make the in-memory data store return Row objects
          rows = client.design_docs[document.to_s].send(index.to_s, default_params.merge(params)).fetch
          rows.map do |row|
            {
              id: row.id,
              value: row.value,
              key: row.key,
              doc: row.doc,
              meta: row.meta
            }
          end
        rescue NoMethodError
          raise IndexMissingError
        end
      end

      # TODO : Test new implementation
      def get(ids)
        if ids.instance_of?(Array)
          rows = client.get(*ids)
          results = []
          rows = [] << rows unless rows.instance_of?(Array)

          rows.each_with_index do |row, index|
            results << wrap_row(ids[index], row)
          end
          results
        else
          wrap_row(ids, client.get(ids))
        end
      end

      def save(data)
        key      = data[:key]
        document = data[:value]

        if key.nil?
          key = _generate_id
          client.add(key, document)
        else
          client.replace(key, document)
        end

        key
      end

    private

      def _generate_id
        SecureRandom.uuid
      end

      def wrap_row(key, data)
        {
          key: key,
          data: data
        }
      end

    end
  end
end
