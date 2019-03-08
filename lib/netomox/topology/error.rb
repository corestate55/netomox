module Netomox
  module Topology
    class TopologyError < StandardError; end
    class TopologyElementNotFoundError < TopologyError; end
  end
end
