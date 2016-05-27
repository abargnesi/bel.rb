module BEL
  module BELRDF
    module StatementConversion
      # Convert a {BELParser::Expression::Model::Statement} to {RDF::Graph} of
      # RDF statements.
      #
      # @param  [BELParser::Expression::Model::Statement] bel_statement
      # @return [RDF::Graph] graph of RDF statements representing the statement
      def bel_statement(bel_statement)
        raise NotImplementedError, "#{__method__} is not implemented."
      end
    end
  end
end
