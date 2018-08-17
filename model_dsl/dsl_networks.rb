require_relative 'dsl_network'

module ModelDSL
  # multiple network container (top)
  class Networks
    def initialize(&block)
      @networks = []
      register(&block) if block_given?
    end

    def register(&block)
      p '# Networks#register'
      instance_eval(&block)
    end

    def network(name, &block)
      @networks.push(Network.new(name, &block))
    end

    def topo_data
      networks = @networks.map(&:topo_data)
      { "#{NS_NW}:networks": { 'network': networks } }
    end
  end
end
