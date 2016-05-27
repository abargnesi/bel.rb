require 'forwardable'

module BEL
  module Nanopub
    class Metadata

      attr_reader :values

      extend Forwardable
      include Enumerable

      BEL_VERSION     = :bel_version
      DOCUMENT_HEADER = :document_header

      def initialize(values = {})
        if values.is_a? Array
          @values = Hash[
            values.map { |item|
              name  = item[:name]  || item['name']
              value = item[:value] || item['value']
              [name.to_sym, value]
            }
          ]
        else
          @values = values
        end
      end

      def bel_version
        @values[BEL_VERSION]
      end

      def bel_version=(bel_version)
        @values[BEL_VERSION] =
          case bel_version
          when BELParser::Language::Specification
            bel_version.version.to_s
          when String
            bel_version
          else
            raise(
              ArgumentError,
              %(expected String, Specification; actual #{bel_version.class}))
          end
      end

      def document_header
        @values[DOCUMENT_HEADER] ||= {}
      end

      def document_header=(document_header)
        @values[DOCUMENT_HEADER] = document_header
      end

      def to_a
        @values.each_pair.map { |key, value|
          {
            name:  key,
            value: value
          }
        }
      end

      def_delegators :@values, :[],    :"[]=", :delete_if, :each, :each_pair,
                               :fetch, :keys,  :size,      :sort, :store
    end
  end
end
