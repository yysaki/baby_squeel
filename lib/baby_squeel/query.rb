require_relative "queryable"

module BabySqueel
  class Query
    include Queryable

    def initialize(scope) # :nodoc:
      self._scope = scope
    end

    def _evaluate(&block) # :nodoc:
      if block.arity.zero?
        instance_eval(&block)
      else
        instance_exec(self, &block)
      end

      _scope
    end

    def select(*columns)
      self._scope = _scope.select(*columns)
      nil
    end

    def where(clause)
      self._scope = _scope.where(clause)
      nil
    end

    def join(association)
      self._scope = _scope.joins(association._construct_join(Arel::Nodes::InnerJoin))
      nil
    end

    def left_join(association)
      self._scope = _scope.joins(association._construct_join(Arel::Nodes::OuterJoin))
      nil
    end

    protected

    attr_accessor :_scope

    private

    def _model
      _scope.klass
    end
  end
end
