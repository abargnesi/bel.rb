require_relative 'namespace'

module BEL
  module Resource

    # TODO Document
    class Namespaces

      include Enumerable

      # TODO This should be available in the RDF module.
      # (e.g. RDF::BELV)
      # Created from a base RdfRepository.
      BELV = ::RDF::Vocabulary.new('http://www.openbel.org/vocabulary/')

      # TODO Document
      QUERY_NAMESPACES = ::RDF::Query.new do
        pattern [:namespace, ::RDF.type, BELV.NamespaceConceptScheme]
      end

      # TODO Document
      def initialize(rdf_repository)
        @rdf_repository = rdf_repository
      end

      # TODO Document
      def each
        if block_given?
          # yield to passed block to each
          _query_namespaces.each { |ns|
            yield Namespace.new(@rdf_repository, ns)
          }
        else
          # return enumerator with results of this method
          to_enum(:each)
        end
      end

      protected

      # TODO Document
      def _query_namespaces
        # TODO: Create Namespace object to map to.
        @rdf_repository.query(QUERY_NAMESPACES).map(&:namespace)
      end

      # TODO Document
      def _query_namespace(id)
        # query by prefix
        solutions = _execute([:namespace, BELV.prefix, id.to_s])
        return solutions.first.namespace unless solutions.empty?

        # query by preferred label
        solutions = _execute([:namespace, ::RDF::SKOS.prefLabel, id.to_s])
        return solutions.first.namespace unless solutions.empty?

        # query by uri
        concept_uri = ::RDF::URI.new(id.to_s)
        solutions = _execute([concept_uri, ::RDF.type, BELV.NamespaceConceptScheme])
        return concept_uri unless solutions.empty?
      end

      private

      def _execute(triple)
        ::RDF::Query.execute(@rdf_repository) do
          pattern(triple)
        end
      end
    end
  end
end
