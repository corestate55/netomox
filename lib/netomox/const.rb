# frozen_string_literal: true

module Netomox
  # Namespace for RFC8345 (Basic object data model)
  NS_NW = 'ietf-network'.freeze
  # Namespace for RFC8345 (Network topology data model)
  NS_TOPO = 'ietf-network-topology'.freeze
  # Namespace for draft-ietf-i2rs-l2-network-topology (L2 network object and topology data model)
  NS_L2NW = 'ietf-l2-topology'.freeze
  # Namespace for RFC8346 (L3 network object and topology data model)
  NS_L3NW = 'ietf-l3-unicast-topology'.freeze
  # Experimental namespace (not defined yang)
  # for ops project
  NS_OPS = 'ops-topology'.freeze
  # for ool-mddo project
  NS_MDDO = 'mddo-topology'.freeze

  # Layer2 network type (draft-ietf-i2rs-l2-network-topology)
  NWTYPE_L2 = "#{NS_L2NW}:l2-network".freeze
  # Layer3 network type (RFC83446)
  NWTYPE_L3 = "#{NS_L3NW}:l3-unicast-topology".freeze
  # Experimental network type
  # for ops project
  NWTYPE_OPS = "#{NS_OPS}:ops-network".freeze
  # for MDDO project
  NWTYPE_MDDO_L1 = "#{NS_MDDO}:l1-network".freeze
  NWTYPE_MDDO_L2 = "#{NS_MDDO}:l2-network".freeze
  NWTYPE_MDDO_L3 = "#{NS_MDDO}:l3-network".freeze
end
