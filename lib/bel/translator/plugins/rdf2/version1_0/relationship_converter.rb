require          'rdf'
require          'bel_parser/language/version1_0'
require_relative 'belv1_0'
require_relative 'rdf_converter'

module BEL
  module BELRDF
    module Version1_0
      class RelationshipConverter
        include BELParser::Language::Version1_0::Relationships
        include RDFConverter

        # Convert a version 1.0 {BELParser::Language::Relationship}
        # to RDF statements.
        #
        # @param  [BELParser::Language::Relationship] relationship
        # @return [RDF::Graph] graph of RDF statements representing the relationship
        def convert(relationship)
          return nil if relationship.nil?
          [relationship.long.to_s, RELATIONSHIP_HASH[relationship]]
        end

        RELATIONSHIP_HASH = {
          Analogous => BELV1_0.Analogous,
          Association => BELV1_0.Association,
          BiomarkerFor => BELV1_0.BiomarkerFor,
          CausesNoChange => BELV1_0.CausesNoChange,
          Decreases => BELV1_0.Decreases,
          DirectlyDecreases => BELV1_0.DirectlyDecreases,
          DirectlyIncreases => BELV1_0.DirectlyIncreases,
          HasComponent => BELV1_0.HasComponent,
          HasMember => BELV1_0.HasMember,
          Increases => BELV1_0.Increases,
          IsA => BELV1_0.IsA,
          NegativeCorrelation => BELV1_0.NegativeCorrelation,
          Orthologous => BELV1_0.Orthologous,
          PositiveCorrelation => BELV1_0.PositiveCorrelation,
          PrognosticBiomarkerFor => BELV1_0.PrognosticBiomarkerFor,
          RateLimitingStepOf => BELV1_0.RateLimitingStepOf,
          SubProcessOf => BELV1_0.SubProcessOf,
          TranscribedTo => BELV1_0.TranscribedTo,
          TranslatedTo => BELV1_0.TranslatedTo
        }.freeze
        # Special
          # HasMembers
          # HasComponents
      end
    end
  end
end

