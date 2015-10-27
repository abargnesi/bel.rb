# XXX Do we want to have a hard dependency on RDF gems?
# It seems like a big capability, but not always required.
require 'rdf'

module BEL
  module Resource

    # TODO Document
    class Namespace

      include Enumerable

      attr_reader :uri

      # TODO This should be available in the RDF module.
      # (e.g. RDF::BELV)
      # Created from a base RdfRepository.
      BELV = ::RDF::Vocabulary.new('http://www.openbel.org/vocabulary/')

      # TODO Document
      def initialize(rdf_repository, uri)
        @rdf_repository = rdf_repository
        @uri            = uri
        @concept_query  = [
          :predicate => ::RDF::SKOS.inScheme,
          :object    => @uri
        ]
      end

      # TODO Document
      def each
        if block_given?
          # yield to passed block to each
          _query_concepts.each { |value| yield value }
        else
          # return enumerator with results of this method
          to_enum(:each)
        end
      end

      # TODO Document
      def each_described
        # TODO Yield or enumerate statements about this NamespaceConceptScheme.
        # (e.g. uri, prefix, prefLabel, species, domain)
      end

      protected

      # TODO Document
      def _query_concepts
        # TODO: Create Namespace object to map to.
        @rdf_repository.query(@concept_query).each.lazy.map(&:subject)
      end
    end
  end
end
