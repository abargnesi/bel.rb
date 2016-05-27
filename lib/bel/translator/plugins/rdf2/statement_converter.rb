require          'rdf'
require_relative 'statement_conversion'

module BEL
  module BELRDF
    class StatementConverter
      include StatementConversion

      def bel_statement(bel_statement)
        RDF::Graph.new
      end
    end
  end
end
