module BEL
  module BELRDF
    module NanopubConversion
      # Convert a {BEL::Nanopub::Nanopub} to {RDF::Graph} of RDF statements.
      #
      # @param  [BEL::Nanopub::Nanopub] nanopub
      # @return [RDF::Graph] graph of RDF statements representing the nanopub
      def nanopub(nanopub)
        raise NotImplementedError, "#{__method__} is not implemented."
      end
    end
  end
end
