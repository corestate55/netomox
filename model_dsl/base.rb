module NWTopoDSL
  class DSLObjectBase
    def register(&block)
      instance_eval(&block)
    end
  end
end
