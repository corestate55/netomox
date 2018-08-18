module NWTopoDSL
  # DSl common methods
  class DSLObjectBase
    def register(&block)
      instance_eval(&block)
    end
  end
end
