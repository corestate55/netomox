# frozen_string_literal: true

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
  NS_OPS = 'ops-topology'

  # Layer2 network type (draft-ietf-i2rs-l2-network-topology)
  NWTYPE_L2 = "#{NS_L2NW}:l2-network"
  # Layer3 network type (RFC83446)
  NWTYPE_L3 = "#{NS_L3NW}:l3-unicast-topology"
  # Experimental network type
  NWTYPE_OPS = "#{NS_OPS}:ops-network"
end
