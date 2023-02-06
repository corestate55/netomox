# frozen_string_literal: true

require_relative 'p_object_base'
require_relative 'p_term_point'

module Netomox
  module PseudoDSL
    # pseudo node
    class PNode < PObjectBase
      # @!attribute [rw] tps
      #   @return [Array<PTermPoint>]
      attr_accessor :tps

      # @param [String] name Name of the network
      def initialize(name)
        super(name)
        @tps = [] # Array<PTermPoint>
      end

      # Generate term-point name automatically
      # @return [String] term-point name
      def auto_tp_name
        tp_names = @tps.map(&:name).filter { |name| name =~ /p\d+/ }
        tp_name_numbers = tp_names.map do |name|
          name =~ /p(\d+)/
          Regexp.last_match(1).to_i
        end.sort
        next_number = tp_name_numbers.length.positive? ? tp_name_numbers.pop + 1 : 1
        "p#{next_number}"
      end

      # Find or create new term-point
      # @param [String] tp_name Name of the term-point
      # @return [PTermPoint] Found or added term-point
      def term_point(tp_name)
        found_tp = find_tp_by_name(tp_name)
        return found_tp if found_tp

        new_tp = PTermPoint.new(tp_name)
        @tps.push(new_tp)
        new_tp
      end

      # @param [String] tp_name Term-point name to find
      # @return [nil, PTermPoint] Term-point if found or nil if not found
      def find_tp_by_name(tp_name)
        @tps.find { |tp| tp.name == tp_name }
      end

      # @param [String] tp_name Term-point name to omit
      # @return [Array<PTermPoint>] Array of term-point without the term-point
      def tps_without(tp_name)
        @tps.reject { |tp| tp.name == tp_name }
      end

      # @return [String] String
      def to_s
        name.to_s
      end
    end
  end
end
