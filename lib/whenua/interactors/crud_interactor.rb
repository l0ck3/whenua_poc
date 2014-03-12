# TODO : Test it !

module Whenua
  module Interactors
    module CrudInteractor
      extend ActiveSupport::Concern

      included do
        entity_model_klass_name = Object.const_set(self.to_s.split('::').join('_') + '_Model', Class.new(Whenua::Models::EntityModel))
        self.instance_variable_set :@model_klass, entity_model_klass_name
      end

      def initialize(attributes: {}, id: nil)
        split_klass     = self.class.to_s.split('::').last.underscore.split('_')
        entity_type     = split_klass.drop(1).join('_').classify

        @action_type    = split_klass.first.to_sym
        @repository     = DB[entity_type.underscore]

        if id
          @entity = @repository.find_by_id(id)
          @entity.update_attributes(attributes)
        else
          @entity = entity_type.to_s.capitalize.constantize.new(attributes)
        end
      end

      def do
        if private_methods.include?(@action_type)
          send(@action_type)
        else
          raise 'Invalid Crud Interactor. Check the naming' # TODO : Raise a real exception
        end
      end

      private

      def new
        (self.class.instance_variable_get :@model_klass).new(@entity)
      end

      def edit
        (self.class.instance_variable_get :@model_klass).new(@entity)
      end

      def save
        model = (self.class.instance_variable_get :@model_klass).new(@entity)
        model.send(:run_validations!)
        if model.valid?
          @repository.save(model.entity)
        end

        model
      end

      module ClassMethods
        def validates(*validation)
          (self.instance_variable_get :@model_klass).validates(*validation)
        end
      end

    end
  end
end

