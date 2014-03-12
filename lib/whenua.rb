#require 'whenua/version'
require_relative 'whenua/exceptions'
require_relative 'whenua/couchbase/data_store' # TODO : Conditional loading of datastores
require_relative 'whenua/memory/data_store' # TODO : Conditional loading of datastores
require_relative 'whenua/entity'
require_relative 'whenua/repository'
require_relative 'whenua/models'
require_relative 'whenua/interactors'

module Whenua
  module DB
    def self.register_datastore(name, type, params={})
      @@datastores       ||= {}
      datastore_klass    = "Whenua::#{type.capitalize}::DataStore".constantize
      @@datastores[name.to_sym] = datastore_klass.new(params)
    end

    def self.register_repository(name, entity, datastore)
      @@repositories   ||= {}
      repository_klass = "::#{entity.capitalize}Repository".constantize
      datastore        = @@datastores[datastore.to_sym]
      @@repositories[name.to_sym] = repository_klass.new(datastore)
    end

    def self.[](name)
      @@repositories[name.to_sym]
    end
  end
end
