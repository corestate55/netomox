module Netomox
  module DSL
    # DSl common methods
    class DSLObjectBase
      def register(&block)
        instance_eval(&block)
      end
    end
  end
end
