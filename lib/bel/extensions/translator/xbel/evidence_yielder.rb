require 'rexml/document'
require_relative 'evidence_handler'

module BEL::Extension

  module XBEL

    class EvidenceYielder

      def initialize(io)
        @io = io
      end

      def each(&block)
        if block_given?
          handler = EvidenceHandler.new(block)
          REXML::Document.parse_stream(@io, handler)
        else
          to_enum(:each)
        end
      end
    end
  end
end
