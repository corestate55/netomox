# frozen_string_literal: true

require 'logger'

# Network Topology Modeling Toolbox
module Netomox
  # Namespace for RFC8345 (Basic object data model)
  NS_NW = 'ietf-network'
  # Namespace for RFC8345 (Network topology data model)
  NS_TOPO = 'ietf-network-topology'
  # Namespace for draft-ietf-i2rs-l2-network-topology (L2 network object and topology data model)
  NS_L2NW = 'ietf-l2-topology'
  # Namespace for RFC8346 (L3 network object and topology data model)
  NS_L3NW = 'ietf-l3-unicast-topology'
  # Experimental namespace (not defined yang)
  # for ops project
  NS_OPS = 'ops-topology'
  # for ool-mddo project
  NS_MDDO = 'mddo-topology'

  # Layer2 network type (draft-ietf-i2rs-l2-network-topology)
  NWTYPE_L2 = "#{NS_L2NW}:l2-network".freeze
  # Layer3 network type (RFC83446)
  NWTYPE_L3 = "#{NS_L3NW}:l3-unicast-topology".freeze
  # Experimental network type
  # for ops project
  NWTYPE_OPS = "#{NS_OPS}:ops-network".freeze
  # for MDDO project
  # MDDO Layer1 network type
  NWTYPE_MDDO_L1 = "#{NS_MDDO}:l1-network".freeze
  # MDDO Layer2 network type
  NWTYPE_MDDO_L2 = "#{NS_MDDO}:l2-network".freeze
  # MDDO L3 network type
  NWTYPE_MDDO_L3 = "#{NS_MDDO}:l3-network".freeze
  # MDDO ospf-area network type
  NWTYPE_MDDO_OSPF_AREA = "#{NS_MDDO}:ospf-area-network".freeze

  # logger for netomox
  @logger = Logger.new($stderr)
  @logger.progname = 'netomox'
  @logger.level = case ENV.fetch('NETOMOX_LOG_LEVEL', nil)
                  when /fatal/i
                    Logger::FATAL
                  when /error/i
                    Logger::ERROR
                  when /warn/i
                    Logger::WARN
                  when /debug/i
                    Logger::DEBUG
                  else
                    Logger::INFO # default
                  end

  module_function

  # @return [Logger]
  def logger
    @logger
  end
end
