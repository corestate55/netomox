# frozen_string_literal: true

module Netomox
  module Topology
    # Error for Netomox::Topology
    class TopologyError < StandardError; end
    # Error when topology object not found (for topology data verification)
    class TopologyElementNotFoundError < TopologyError; end
  end
end
