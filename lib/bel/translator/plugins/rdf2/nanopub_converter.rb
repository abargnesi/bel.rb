require_relative 'nanopub_conversion'
require_relative 'uuid'

module BEL
  module BELRDF
    class NanopubConverter
      include NanopubConversion

      def initialize(statement_converter)
        @statement_converter = statement_converter
      end

      def nanopub(nanopub)
        resource = generate_nanopub_uri
        graph    = RDF::Graph.new(resource)

        bel_statement(nanopub.bel_statement, resource, graph)
        citation(nanopub.citation, resource, graph)
        support(nanopub.support, resource, graph)
        experiment_context(nanopub.experiment_context, resource, graph)
        references(nanopub.references, resource, graph)
        metadata(nanopub.metadata, resource, graph)

        graph
      end

      protected

      def bel_statement(statement, nr, ng)
        ng << @statement_converter.bel_statement(statement)
      end

      def citation(citation, nr, ng)
        type = citation.type
        if type && (type.to_s.downcase == 'pubmed')
          ng << s(nr, BELV2_0.hasCitation, PUBMED[citation.id.to_s])
        end
      end

      def support(support, nr, ng)
        ng << s(nr, BELV2_0.hasSupport, support.to_s)
      end

      def experiment_context(experiment_context, nr, ng)
      end

      def references(references, nr, ng)
      end

      def metadata(metadata, nr, ng)
        v = metadata.bel_version
        bel_version(v, nr, ng) if v
      end

      def bel_version(bel_version, nr, ng)
        spec = BELParser::Language.specification(bel_version) rescue nil
        return unless spec

        bel = RDF::URI(spec.uri)
        ng << s(bel, RDF.type, BELV2_0.BiologicalExpressionLanguage)
        ng << s(bel, BELV2_0.hasVersion, spec.version.to_s)
        ng << s(nr, BELV2_0.hasBiologicalExpressionLanguage, bel)
      end

      def s(subject, predicate, object)
        RDF::Statement.new(subject, predicate, object)
      end

      private

      # @api private
      def generate_nanopub_uri
        BELN[BELRDF.generate_uuid]
      end
    end
  end
end
