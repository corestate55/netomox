# frozen_string_literal: true

require 'netomox/const'
require 'netomox/dsl/tp_attr/mddo_ospf_timer'
require 'netomox/dsl/tp_attr/mddo_ospf_neighbor'
require 'netomox/dsl/tp_attr/mddo_bgp_timer'

module Netomox
  module DSL
    # attribute for mddo-topology layer1 term-point
    class MddoL1TPAttribute
      # @!attribute [rw] description
      #   @return [String]
      # @!attribute [rw] flags
      #   @return [Array<String>]
      attr_accessor :description, :flags
      # @!attribute [r] type
      #   @return [String]
      attr_reader :type

      # @param [String] description Interface description
      # @param [Array<String>] flags Flags
      def initialize(description: '', flags: [])
        @description = description || '' # avoid nil if the interface doesn't have description
        @flags = flags
        @type = "#{NS_MDDO}:l1-termination-point-attributes"
      end

      # Convert to RFC8345 topology data
      # @return [Hash]
      def topo_data
        {
          'description' => @description,
          'flag' => @flags
        }
      end

      # @return [Boolean]
      def empty?
        @description.empty? && @flags.empty?
      end
    end

    # attribute for mddo-topology layer2 term-point
    class MddoL2TPAttribute
      # @!attribute [rw] description
      #   @return [String]
      # @!attribute [rw] encapsulation
      #   @return [String]
      # @!attribute [rw] switchport_mode
      #   @return [String]
      # @!attribute [rw] flags
      #   @return [Array<String>]
      attr_accessor :description, :encapsulation, :switchport_mode, :flags
      # @!attribute [r] type
      #   @return [String]
      attr_reader :type

      # @param [String] description Interface description
      # @param [String] encapsulation VLAN encapsulation
      # @param [String] switchport_mode Switch-port mode
      # @param [Array<String>] flags Flags
      def initialize(description: '', encapsulation: '', switchport_mode: '', flags: [])
        @description = description || '' # avoid nil if the interface doesn't have description
        @encapsulation = encapsulation
        @switchport_mode = switchport_mode
        @flags = flags
        @type = "#{NS_MDDO}:l2-termination-point-attributes"
      end

      # Convert to RFC8345 topology data
      # @return [Hash]
      def topo_data
        {
          'description' => @description,
          'encapsulation' => @encapsulation,
          'switchport-mode' => @switchport_mode,
          'flag' => @flags
        }
      end

      # @return [Boolean]
      def empty?
        @description.empty? && @encapsulation.empty? && @switchport_mode.empty? && flags.empty?
      end
    end

    # attribute for mddo-topology layer3 term-point
    class MddoL3TPAttribute
      # @!attribute [rw] description
      #   @return [String]
      # @!attribute [rw] ip_addrs
      #   @return [Array<String>]
      # @!attribute [rw] flags
      #   @return [Array<String>]
      attr_accessor :description, :ip_addrs, :flags
      # @!attribute [r] type
      #   @return [String]
      attr_reader :type

      # @param [String] description Interface description
      # @param [Array<String>] ip_addrs IP addresses
      # @param [Array<String>] flags Flags
      def initialize(description: '', ip_addrs: [], flags: [])
        @description = description || '' # avoid nil if the interface doesn't have description
        @ip_addrs = ip_addrs
        @flags = flags
        @type = "#{NS_MDDO}:l3-termination-point-attributes"
      end

      # Convert to RFC8345 topology data
      # @return [Hash]
      def topo_data
        {
          'description' => @description,
          'ip-address' => @ip_addrs,
          'flag' => @flags
        }
      end

      # @return [Boolean]
      def empty?
        @description.empty? && @ip_addrs.empty? && @flags.empty?
      end
    end

    # attribute for mddo topology ospf-area term-point
    class MddoOspfAreaTPAttribute
      # TODO: network_type: Enum {p2p, broadcast, non_broadcast}

      # @!attribute [rw] network_type
      #   @return [String]
      # @!attribute [rw] priority
      #   @return [Integer]
      # @!attribute [rw] metric
      #   @return [Integer]
      # @!attribute [rw] passive
      #   @return [Boolean]
      # @!attribute [rw] timer
      #   @return [MddoOspfTimer]
      # @!attribute [rw] area
      #   @return [Integer]
      attr_accessor :network_type, :priority, :metric, :passive, :timer, :area
      # @!attribute [r] type
      #   @return [String]
      attr_reader :type

      # rubocop:disable Metrics/ParameterLists

      # @param [String] network_type
      # @param [Integer] priority
      # @param [Integer] metric
      # @param [Boolean] passive
      # @param [Hash] timer
      # @param [Array<Hash>] neighbors
      # @param [Integer] area
      def initialize(network_type: '', priority: 10, metric: 1, passive: false, timer: {}, neighbors: [], area: -1)
        @network_type = network_type # TODO: network type selection
        @priority = priority
        @metric = metric
        @passive = passive
        @timer = MddoOspfTimer.new(**timer)
        @neighbors = neighbors.map { |n| MddoOspfNeighbor.new(**n) }
        @area = area
        @type = "#{NS_MDDO}:ospf-area-termination-point-attributes"
      end
      # rubocop:enable Metrics/ParameterLists

      # Convert to RFC8345 topology data
      # @return [Hash]
      def topo_data
        {
          'network-type' => @network_type,
          'priority' => @priority,
          'metric' => @metric,
          'passive' => @passive,
          'timer' => @timer.topo_data,
          'neighbor' => @neighbors.map(&:topo_data),
          'area' => @area
        }
      end

      # @return [Boolean]
      def empty?
        false
      end
    end

    # attribute for mddo-topology bgp-proc term-point
    class MddoBgpProcTPAttribute
      # @!attribute [rw] local_as
      #   @return [Integer]
      # @!attribute [rw] local_ip
      #   @return [String]
      # @!attribute [rw] remote_as
      #   @return [Integer]
      # @!attribute [rw] remote_ip
      #   @return [String]
      # @!attribute [rw] description
      #   @return [String]
      # @!attribute [rw] confederation
      #   @return [Integer] ASN
      # @!attribute [rw] route_reflector_client
      #   @return [Boolean]
      # @!attribute [rw] cluster_id
      #   @return [String] IP
      # @!attribute [rw] peer_group
      #   @return [String]
      # @!attribute [rw] import_policies
      #   @return [Array<String>]
      # @!attribute [rw] export_policies
      #   @return [Array<String>]
      # @!attribute [rw] timer
      #   @return [MddoBgpTimer]
      attr_accessor :local_as, :local_ip, :remote_as, :remote_ip, :description, :confederation, :route_reflector_client,
                    :cluster_id, :peer_group, :import_policies, :export_policies, :timer
      # @!attribute [r] type
      #   @return [String]
      attr_reader :type

      # rubocop:disable Metrics/ParameterLists

      # @param [Integer] local_as Local ASN
      # @param [String] local_ip Local IP address
      # @param [Integer] remote_as Remote ASN
      # @param [String] remote_ip Remote IP address
      # @param [String] description
      # @param [Integer] confederation
      # @param [Boolean] route_reflector_client
      # @param [String] cluster_id
      # @param [String] peer_group
      # @param [Array<String>] import_policies
      # @param [Array<String>] export_policies
      # @timer [MddoBgpTimer] timer
      def initialize(local_as: -1, local_ip: '', remote_as: -1, remote_ip: '', description: '', confederation: -1,
                     route_reflector_client: false, cluster_id: '', peer_group: '', import_policies: [],
                     export_policies: [], timer: {})
        @local_as = local_as
        @local_ip = local_ip
        @remote_as = remote_as
        @remote_ip = remote_ip
        @description = description
        @confederation = confederation
        @route_reflector_client = route_reflector_client
        @cluster_id = cluster_id
        @peer_group = peer_group
        @import_policies = import_policies
        @export_policies = export_policies
        @timer = MddoBgpTimer.new(**timer)
        @type = "#{NS_MDDO}:bgp-proc-termination-point-attributes"
      end
      # rubocop:enable Metrics/ParameterLists

      # Convert to RFC8345 topology data
      # @return [Hash]
      def topo_data
        {
          'local-as' => @local_as,
          'local-ip' => @local_ip,
          'remote-as' => @remote_as,
          'remote-ip' => @remote_ip,
          'description' => @description,
          'confederation' => @confederation,
          'route-reflector-client' => @route_reflector_client,
          'cluster-id' => @cluster_id,
          'peer-group' => @peer_group,
          'import-policy' => @import_policies,
          'export-policy' => @export_policies,
          'timer' => @timer.topo_data
        }
      end

      # @return [Boolean]
      def empty?
        @local_as.negative?
      end
    end

    # attribute for mddo-topology bgp-as term-point
    class MddoBgpAsTPAttribute < MddoL1TPAttribute
      # @param [String] description Interface description
      # @param [Array<String>] flags Flags
      def initialize(description: '', flags: [])
        super(description:, flags:)
        @type = "#{NS_MDDO}:bgp-as-termination-point-attributes"
      end
    end
  end
end
