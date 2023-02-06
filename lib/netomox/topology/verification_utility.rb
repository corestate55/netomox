# frozen_string_literal: true

module Netomox
  module Topology
    # Check result (message)
    class CheckMessage
      # @!attribute [rw] severity
      #   @return [Symbol]
      # @!attribute [rw] path
      #   @return [String]
      # @!attribute [rw] message
      #   @return [String]
      attr_accessor :severity, :path, :message

      # @param [Symbol] severity
      # @return [String] path Target object path
      # @param [String] message
      def initialize(severity, path, message)
        @severity = severity
        @path = path
        @message = message
      end

      # @return [Hash] Converted data
      def to_data
        {
          severity: @severity,
          path: @path,
          message: @message
        }
      end
    end

    # Check result
    class CheckResult
      # @!attribute [rw] checkup
      #   @return [String]
      # @!attribute [rw] messages
      #   @return [Array<CheckResult>]
      attr_accessor :checkup, :messages

      # @param [String] description Check description
      def initialize(description)
        @checkup = description
        @messages = []
      end

      # @return [Hash] Converted data
      def to_data
        {
          checkup: @checkup,
          messages: @messages.map(&:to_data)
        }
      end
    end
  end
end
