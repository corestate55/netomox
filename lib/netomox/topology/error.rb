# frozen_string_literal: true

module Netomox
  module Topology
    class TopologyError < StandardError; end
    class TopologyElementNotFoundError < TopologyError; end
  end
end
