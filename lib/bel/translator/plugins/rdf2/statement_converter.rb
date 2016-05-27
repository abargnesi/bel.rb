require          'rdf'

module BEL
  module BELRDF
    class StatementConverter
      # Convert a {BELParser::Expression::Model::Statement} to {RDF::Graph} of
      # RDF statements.
      #
      # @param  [BELParser::Expression::Model::Statement] bel_statement
      # @return [RDF::Graph] graph of RDF statements representing the statement
      def convert(bel_statement)
        RDF::Graph.new
      end
    end
  end
end
