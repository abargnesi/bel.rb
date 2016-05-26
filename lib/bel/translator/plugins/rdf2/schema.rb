require 'rdf/turtle'

module BEL
  module RDF
    class Schema
      def initialize(ttl_file)
        @sg = RDF::Graph.load(ttl_file, format:  :ttl)
      end

      # TODO Also create a BELV1_0 strict vocabulary.

      class BELV2_0 < RDF::StrictVocabulary('http://www.openbel.org/vocabulary/')
        include RDF::Vocab

        # Concept classes
        term :AnnotationConcept,
          RDF.type        => RDFS.Class,
          RDFS.subClassOf => SKOS.Concept
        term :AnnotationConceptScheme,
          RDF.type        => RDFS.Class,
          RDFS.subClassOf => SKOS.ConceptScheme
        term :NamespaceConcept,
          RDF.type        => RDFS.Class,
          RDFS.subClassOf => SKOS.Concept
        term :NamespaceConceptScheme,
          RDF.type        => RDFS.Class,
          RDFS.subClassOf => SKOS.ConceptScheme
        term :AbundanceConcept,
          RDF.type        => RDFS.Class,
          RDFS.subClassOf => BELV2_0.NamespaceConcept
        term :BiologicalProcessConcept,
          RDF.type        => RDFS.Class,
          RDFS.subClassOf => BELV2_0.NamespaceConcept
        term :ComplexConcept,
          RDF.type        => RDFS.Class,
          RDFS.subClassOf => BELV2_0.AbundanceConcept
        term :CompositeConcept,
          RDF.type        => RDFS.Class,
          RDFS.subClassOf => BELV2_0.AbundanceConcept
        term :GeneConcept,
          RDF.type        => RDFS.Class,
          RDFS.subClassOf => BELV2_0.AbundanceConcept
        term :LocationConcept,
          RDF.type        => RDFS.Class,
          RDFS.subClassOf => BELV2_0.NamespaceConcept
        term :MicroRNAConcept,
          RDF.type        => RDFS.Class,
          RDFS.subClassOf => BELV2_0.RNAConcept
        term :MolecularActivityConcept,
          RDF.type        => RDFS.Class,
          RDFS.subClassOf => BELV2_0.NamespaceConcept
        term :PathologyConcept,
          RDF.type        => RDFS.Class,
          RDFS.subClassOf => BELV2_0.BiologicalProcessConcept
        term :ProteinConcept,
          RDF.type        => RDFS.Class,
          RDFS.subClassOf => BELV2_0.AbundanceConcept
        term :ProteinModificationConcept,
          RDF.type        => RDFS.Class,
          RDFS.subClassOf => BELV2_0.NamespaceConcept
        term :RNAConcept,
          RDF.type        => RDFS.Class,
          RDFS.subClassOf => BELV2_0.AbundanceConcept

        # Nanopub classes
        term :Abundance,
          RDF.type => RDFS.Class
        term :Nanopub,
          RDF.type => RDFS.Class
        term :Process,
          RDF.type => RDFS.Class
        term :Relationship,
          RDF.type => RDFS.Class
        term :Statement,
          RDF.type => RDFS.Class
        term :Term,
          RDF.type => RDFS.Class

        # Relationship categories
        term :CausalRelationship,
          RDF.type        => RDFS.Class,
          RDFS.subClassOf => BELV2_0.Relationship
        term :CorrelativeRelationship,
          RDF.type        => RDFS.Class,
          RDFS.subClassOf => BELV2_0.Relationship
        term :DirectRelationship,
          RDF.type        => RDFS.Class,
          RDFS.subClassOf => BELV2_0.Relationship
        term :GenomicRelationship,
          RDF.type        => RDFS.Class,
          RDFS.subClassOf => BELV2_0.Relationship
        term :MembershipRelationship,
          RDF.type        => RDFS.Class,
          RDFS.subClassOf => BELV2_0.Relationship
        term :NegativeRelationship,
          RDF.type        => RDFS.Class,
          RDFS.subClassOf => BELV2_0.Relationship
        term :PositiveRelationship,
          RDF.type        => RDFS.Class,
          RDFS.subClassOf => BELV2_0.Relationship

        # Relationship types
        term :Analogous,
          RDF.type        => RDFS.Class,
          RDFS.subClassOf => BELV2_0.GenomicRelationship
        term :BiomarkerFor,
          RDF.type        => RDFS.Class,
          RDFS.subClassOf => BELV2_0.Relationship
        term :Association,
          RDF.type        => RDFS.Class,
          RDFS.subClassOf => BELV2_0.CorrelativeRelationship
        term :CausesNoChange,
          RDF.type        => RDFS.Class,
          RDFS.subClassOf => BELV2_0.CausalRelationship
        term :Decreases,
          RDF.type        => RDFS.Class,
          RDFS.subClassOf => [
            BELV2_0.CausalRelationship,
            BELV2_0.NegativeRelationship
          ]
        term :DirectlyDecreases,
          RDF.type        => RDFS.Class,
          RDFS.subClassOf => [
            BELV2_0.CausalRelationship,
            BELV2_0.Decreases,
            BELV2_0.DirectRelationship,
            BELV2_0.NegativeRelationship
          ]
        term :DirectlyIncreases,
          RDF.type        => RDFS.Class,
          RDFS.subClassOf => [
            BELV2_0.CausalRelationship,
            BELV2_0.DirectRelationship,
            BELV2_0.Increases,
            BELV2_0.PositiveRelationship
          ]
        term :HasComponent,
          RDF.type        => RDFS.Class,
          RDFS.subClassOf => BELV2_0.MembershipRelationship
        term :HasMember,
          RDF.type        => RDFS.Class,
          RDFS.subClassOf => BELV2_0.MembershipRelationship
        term :Increases,
          RDF.type        => RDFS.Class,
          RDFS.subClassOf => BELV2_0.CausalRelationship
        term :IsA,
          RDF.type        => RDFS.Class,
          RDFS.subClassOf => BELV2_0.MembershipRelationship
        term :NegativeCorrelation,
          RDF.type        => RDFS.Class,
          RDFS.subClassOf => [
            BELV2_0.CorrelativeRelationship,
            BELV2_0.NegativeRelationship
          ]
        term :Orthologous,
          RDF.type        => RDFS.Class,
          RDFS.subClassOf => BELV2_0.GenomicRelationship
        term :PositiveCorrelation,
          RDF.type        => RDFS.Class,
          RDFS.subClassOf => [
            BELV2_0.CorrelativeRelationship,
            BELV2_0.PositiveRelationship
          ]
        term :PrognosticBiomarkerFor,
          RDF.type        => RDFS.Class,
          RDFS.subClassOf => BELV2_0.BiomarkerFor
        term :RateLimitingStepOf,
          RDF.type        => RDFS.Class,
          RDFS.subClassOf => [
            BELV2_0.CausalRelationship,
            BELV2_0.Increases,
            BELV2_0.SubProcessOf
          ]
        term :Regulates,
          RDF.type        => RDFS.Class,
          RDFS.subClassOf => BELV2_0.CausalRelationship
        term :SubProcessOf,
          RDF.type        => RDFS.Class,
          RDFS.subClassOf => BELV2_0.MembershipRelationship
        term :TranscribedTo,
          RDF.type        => RDFS.Class,
          RDFS.subClassOf => BELV2_0.GenomicRelationship
        term :TranslatedTo,
          RDF.type        => RDFS.Class,
          RDFS.subClassOf => BELV2_0.GenomicRelationship

        # Process classes
        term :BiologicalProcess,
          RDF.type        => RDFS.Class,
          RDFS.subClassOf => BELV2_0.Process
        term :CellSecretion,
          RDF.type        => RDFS.Class,
          RDFS.subClassOf => BELV2_0.Translocation
        term :CellSurfaceExpression,
          RDF.type        => RDFS.Class,
          RDFS.subClassOf => BELV2_0.Translocation
        term :Degradation,
          RDF.type        => RDFS.Class,
          RDFS.subClassOf => BELV2_0.Transformation
        term :Pathology,
          RDF.type        => RDFS.Class,
          RDFS.subClassOf => BELV2_0.BiologicalProcess
        term :Reaction,
          RDF.type        => RDFS.Class,
          RDFS.subClassOf => BELV2_0.Transformation
        term :Transformation,
          RDF.type        => RDFS.Class,
          RDFS.subClassOf => BELV2_0.Process
        term :Translocation,
          RDF.type        => RDFS.Class,
          RDFS.subClassOf => BELV2_0.Transformation

        # Abundance classes
        term :ComplexAbundance,
          RDF.type        => RDFS.Class,
          RDFS.subClassOf => BELV2_0.Abundance
        term :CompositeAbundance,
          RDF.type        => RDFS.Class,
          RDFS.subClassOf => BELV2_0.Abundance
        term :FusionAbundance,
          RDF.type        => RDFS.Class,
          RDFS.subClassOf => BELV2_0.Abundance
        term :GeneAbundance,
          RDF.type        => RDFS.Class,
          RDFS.subClassOf => BELV2_0.Abundance
        term :MicroRNAAbundance,
          RDF.type        => RDFS.Class,
          RDFS.subClassOf => BELV2_0.Abundance
        term :ModifiedProteinAbundance,
          RDF.type        => RDFS.Class,
          RDFS.subClassOf => BELV2_0.ProteinAbundance
        term :ProteinAbundance,
          RDF.type        => RDFS.Class,
          RDFS.subClassOf => BELV2_0.Abundance
        term :RNAAbundance,
          RDF.type        => RDFS.Class,
          RDFS.subClassOf => BELV2_0.Abundance

        # Molecular activities e.g. act(p(HGNC:FOXO1), ma(tscript))
        term :Activity,
          RDF.type        => RDFS.Class,
          RDFS.subClassOf => BELV2_0.Process

        # Protein modification
        term :ProteinModification,
          RDF.type        => RDFS.Class,

      end
    end
  end
end
