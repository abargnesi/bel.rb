require 'rdf'
require 'rdf/turtle'
require 'rdf/vocab'

module BEL
  module BELRDF
    module Version1_0
      # Vocabulary constant for Nanopub instances (non-strict).
      BELN   = RDF::Vocabulary.new('http://www.openbel.org/nanopub/')
      BELR   = RDF::Vocabulary.new('http://www.openbel.org/bel/')
      PUBMED = RDF::Vocabulary.new('http://bio2rdf.org/pubmed:')

      class BELV1_0 < RDF::StrictVocabulary('http://www.openbel.org/vocabulary/')
        RDFS = RDF::Vocab::RDFS
        SKOS = RDF::Vocab::SKOS
        XSD  = RDF::Vocab::XSD

        # Concept classes
        term :AnnotationConcept,
          RDF.type           => RDFS.Class,
          RDFS.subClassOf    => SKOS.Concept
        term :AnnotationConceptScheme,
          RDF.type           => RDFS.Class,
          RDFS.subClassOf    => SKOS.ConceptScheme
        term :NamespaceConcept,
          RDF.type           => RDFS.Class,
          RDFS.subClassOf    => SKOS.Concept
        term :NamespaceConceptScheme,
          RDF.type           => RDFS.Class,
          RDFS.subClassOf    => SKOS.ConceptScheme
        term :AbundanceConcept,
          RDF.type           => RDFS.Class,
          RDFS.subClassOf    => BELV1_0.NamespaceConcept
        term :BiologicalProcessConcept,
          RDF.type           => RDFS.Class,
          RDFS.subClassOf    => BELV1_0.NamespaceConcept
        term :ComplexConcept,
          RDF.type           => RDFS.Class,
          RDFS.subClassOf    => BELV1_0.AbundanceConcept
        term :CompositeConcept,
          RDF.type           => RDFS.Class,
          RDFS.subClassOf    => BELV1_0.AbundanceConcept
        term :GeneConcept,
          RDF.type           => RDFS.Class,
          RDFS.subClassOf    => BELV1_0.AbundanceConcept
        term :RNAConcept,
          RDF.type           => RDFS.Class,
          RDFS.subClassOf    => BELV1_0.AbundanceConcept
        term :MicroRNAConcept,
          RDF.type           => RDFS.Class,
          RDFS.subClassOf    => BELV1_0.RNAConcept
        term :PathologyConcept,
          RDF.type           => RDFS.Class,
          RDFS.subClassOf    => BELV1_0.BiologicalProcessConcept
        term :ProteinConcept,
          RDF.type           => RDFS.Class,
          RDFS.subClassOf    => BELV1_0.AbundanceConcept

        # Evidence classes
        term :Evidence,
          RDF.type           => RDFS.Class
        term :Relationship,
          RDF.type           => RDFS.Class
        term :Statement,
          RDF.type           => RDFS.Class
        term :Term,
          RDF.type           => RDFS.Class

        # BiologicalExpressionLanguage class
        term :BiologicalExpressionLanguage,
          RDF.type           => RDFS.Class

        # Relationship categories
        term :CausalRelationship,
          RDF.type           => RDFS.Class,
          RDFS.subClassOf    => BELV1_0.Relationship
        term :CorrelativeRelationship,
          RDF.type           => RDFS.Class,
          RDFS.subClassOf    => BELV1_0.Relationship
        term :DirectRelationship,
          RDF.type           => RDFS.Class,
          RDFS.subClassOf    => BELV1_0.Relationship
        term :GenomicRelationship,
          RDF.type           => RDFS.Class,
          RDFS.subClassOf    => BELV1_0.Relationship
        term :MembershipRelationship,
          RDF.type           => RDFS.Class,
          RDFS.subClassOf    => BELV1_0.Relationship
        term :NegativeRelationship,
          RDF.type           => RDFS.Class,
          RDFS.subClassOf    => BELV1_0.Relationship
        term :PositiveRelationship,
          RDF.type           => RDFS.Class,
          RDFS.subClassOf    => BELV1_0.Relationship

        # Relationship types
        term :Analogous,
          RDF.type           => RDFS.Class,
          RDFS.subClassOf    => BELV1_0.GenomicRelationship
        term :BiomarkerFor,
          RDF.type           => RDFS.Class,
          RDFS.subClassOf    => BELV1_0.Relationship
        term :Association,
          RDF.type           => RDFS.Class,
          RDFS.subClassOf    => BELV1_0.CorrelativeRelationship
        term :CausesNoChange,
          RDF.type           => RDFS.Class,
          RDFS.subClassOf    => BELV1_0.CausalRelationship
        term :Decreases,
          RDF.type           => RDFS.Class,
          RDFS.subClassOf    => [
            BELV1_0.CausalRelationship,
            BELV1_0.NegativeRelationship
          ]
        term :DirectlyDecreases,
          RDF.type           => RDFS.Class,
          RDFS.subClassOf    => [
            BELV1_0.CausalRelationship,
            BELV1_0.Decreases,
            BELV1_0.DirectRelationship,
            BELV1_0.NegativeRelationship
          ]
        term :Increases,
          RDF.type           => RDFS.Class,
          RDFS.subClassOf    => [
            BELV1_0.CausalRelationship,
            BELV1_0.PositiveRelationship
          ]
        term :DirectlyIncreases,
          RDF.type           => RDFS.Class,
          RDFS.subClassOf    => [
            BELV1_0.CausalRelationship,
            BELV1_0.DirectRelationship,
            BELV1_0.Increases,
            BELV1_0.PositiveRelationship
          ]
        term :HasComponent,
          RDF.type           => RDFS.Class,
          RDFS.subClassOf    => BELV1_0.MembershipRelationship
        term :HasMember,
          RDF.type           => RDFS.Class,
          RDFS.subClassOf    => BELV1_0.MembershipRelationship
        term :IsA,
          RDF.type           => RDFS.Class,
          RDFS.subClassOf    => BELV1_0.MembershipRelationship
        term :NegativeCorrelation,
          RDF.type           => RDFS.Class,
          RDFS.subClassOf    => [
            BELV1_0.CorrelativeRelationship,
            BELV1_0.NegativeRelationship
          ]
        term :Orthologous,
          RDF.type           => RDFS.Class,
          RDFS.subClassOf    => BELV1_0.GenomicRelationship
        term :PositiveCorrelation,
          RDF.type           => RDFS.Class,
          RDFS.subClassOf    => [
            BELV1_0.CorrelativeRelationship,
            BELV1_0.PositiveRelationship
          ]
        term :PrognosticBiomarkerFor,
          RDF.type           => RDFS.Class,
          RDFS.subClassOf    => BELV1_0.BiomarkerFor
        term :SubProcessOf,
          RDF.type           => RDFS.Class,
          RDFS.subClassOf    => BELV1_0.MembershipRelationship
        term :RateLimitingStepOf,
          RDF.type           => RDFS.Class,
          RDFS.subClassOf    => [
            BELV1_0.CausalRelationship,
            BELV1_0.Increases,
            BELV1_0.SubProcessOf
          ]
        term :TranscribedTo,
          RDF.type           => RDFS.Class,
          RDFS.subClassOf    => BELV1_0.GenomicRelationship
        term :TranslatedTo,
          RDF.type           => RDFS.Class,
          RDFS.subClassOf    => BELV1_0.GenomicRelationship

        # Process classes
        term :Process,
          RDF.type           => RDFS.Class
        term :Activity,
          RDF.type           => RDFS.Class,
          RDFS.subClassOf    => BELV.Process
        term :BiologicalProcess,
          RDF.type           => RDFS.Class,
          RDFS.subClassOf    => BELV1_0.Process
        term :Transformation,
          RDF.type           => RDFS.Class,
          RDFS.subClassOf    => BELV1_0.Process
        term :Translocation,
          RDF.type           => RDFS.Class,
          RDFS.subClassOf    => BELV1_0.Transformation
        term :CellSecretion,
          RDF.type           => RDFS.Class,
          RDFS.subClassOf    => BELV1_0.Translocation
        term :CellSurfaceExpression,
          RDF.type           => RDFS.Class,
          RDFS.subClassOf    => BELV1_0.Translocation
        term :Degradation,
          RDF.type           => RDFS.Class,
          RDFS.subClassOf    => BELV1_0.Transformation
        term :Pathology,
          RDF.type           => RDFS.Class,
          RDFS.subClassOf    => BELV1_0.BiologicalProcess
        term :Reaction,
          RDF.type           => RDFS.Class,
          RDFS.subClassOf    => BELV1_0.Transformation

        # Abundance classes
        term :Abundance,
          RDF.type           => RDFS.Class
        term :ComplexAbundance,
          RDF.type           => RDFS.Class,
          RDFS.subClassOf    => BELV1_0.Abundance
        term :CompositeAbundance,
          RDF.type           => RDFS.Class,
          RDFS.subClassOf    => BELV1_0.Abundance
        term :FusionAbundance,
          RDF.type           => RDFS.Class,
          RDFS.subClassOf    => BELV1_0.Abundance
        term :GeneAbundance,
          RDF.type           => RDFS.Class,
          RDFS.subClassOf    => BELV1_0.Abundance
        term :MicroRNAAbundance,
          RDF.type           => RDFS.Class,
          RDFS.subClassOf    => BELV1_0.Abundance
        term :ProteinAbundance,
          RDF.type           => RDFS.Class,
          RDFS.subClassOf    => BELV1_0.Abundance
        term :ModifiedProteinAbundance,
          RDF.type           => RDFS.Class,
          RDFS.subClassOf    => BELV1_0.ProteinAbundance
        term :ProteinVariantAbundance,
          RDF.type           => RDFS.Class,
          RDFS.subClassOf    => BELV1_0.ProteinAbundance
        term :RNAAbundance,
          RDF.type           => RDFS.Class,
          RDFS.subClassOf    => BELV1_0.Abundance

        # Activity types
        term :Catalytic,
          RDF.type           => RDFS.Class,
          RDFS.subClassOf    => BELV1_0.Activity
        term :Chaperone,
          RDF.type           => RDFS.Class,
          RDFS.subClassOf    => BELV1_0.Activity
        term :GtpBound,
          RDF.type           => RDFS.Class,
          RDFS.subClassOf    => BELV1_0.Activity
        term :Kinase,
          RDF.type           => RDFS.Class,
          RDFS.subClassOf    => BELV1_0.Activity
        term :Peptidase,
          RDF.type           => RDFS.Class,
          RDFS.subClassOf    => BELV1_0.Activity
        term :Phosphatase,
          RDF.type           => RDFS.Class,
          RDFS.subClassOf    => BELV1_0.Activity
        term :Ribosylase,
          RDF.type           => RDFS.Class,
          RDFS.subClassOf    => BELV1_0.Activity
        term :Transcription,
          RDF.type           => RDFS.Class,
          RDFS.subClassOf    => BELV1_0.Activity
        term :Transport,
          RDF.type           => RDFS.Class,
          RDFS.subClassOf    => BELV1_0.Activity

        # Protein modification
        term :Modification,
          RDF.type           => RDFS.Class
        term :Acetylation,
          RDF.type           => RDFS.Class,
          RDFS.subClassOf    => BELV1_0.Modification
        term :Farnesylation,
          RDF.type           => RDFS.Class,
          RDFS.subClassOf    => BELV1_0.Modification
        term :Glycosylation,
          RDF.type           => RDFS.Class,
          RDFS.subClassOf    => BELV1_0.Modification
        term :Hydroxylation,
          RDF.type           => RDFS.Class,
          RDFS.subClassOf    => BELV1_0.Modification
        term :Methylation,
          RDF.type           => RDFS.Class,
          RDFS.subClassOf    => BELV1_0.Modification
        term :Phosphorylation,
          RDF.type           => RDFS.Class,
          RDFS.subClassOf    => BELV1_0.Modification
        term :Ribosylase,
          RDF.type           => RDFS.Class,
          RDFS.subClassOf    => BELV1_0.Modification
        term :Sumoylation,
          RDF.type           => RDFS.Class,
          RDFS.subClassOf    => BELV1_0.Modification
        term :Ubiquitination,
          RDF.type           => RDFS.Class,
          RDFS.subClassOf    => BELV1_0.Modification

        # Molecular activity properties
        property :hasActivityType,
          RDF.type           => RDF.Property,
          RDFS.domain        => BELV1_0.Term,
          RDFS.range         => BELV1_0.Activity

        # Reaction properties
        property :hasProduct,
          RDF.type           => RDF.Property,
          RDFS.domain        => BELV1_0.Reaction,
          RDFS.range         => BELV1_0.Abundance
        property :hasReactant,
          RDF.type           => RDF.Property,
          RDFS.domain        => BELV1_0.Reaction,
          RDFS.range         => BELV1_0.Abundance

        # Term properties
        property :hasChild,
          RDF.type           => RDF.Property,
          RDFS.domain        => BELV1_0.Term,
          RDFS.range         => BELV1_0.Term
        property :hasConcept,
          RDF.type           => RDF.Property,
          RDFS.domain        => BELV1_0.Term,
          RDFS.range         => BELV1_0.NamespaceConcept

        # Protein Modification properties
        property :hasModificationType,
          RDF.type           => RDF.Property,
          RDFS.domain        => BELV1_0.ModifiedProteinAbundance,
          RDFS.range         => BELV1_0.Modification
        property :hasModificationPosition,
          RDF.type           => RDF.Property,
          RDFS.domain        => BELV1_0.ModifiedProteinAbundance,
          RDFS.range         => XSD.integer

        # Statement properties
        property :hasSubject,
          RDF.type           => RDF.Property,
          RDFS.subPropertyOf => BELV1_0.hasChild,
          RDFS.domain        => BELV1_0.Statement,
          RDFS.range         => BELV1_0.Term
        property :hasRelationship,
          RDF.type           => RDF.Property,
          RDFS.domain        => BELV1_0.Statement,
          RDFS.range         => BELV1_0.Relationship
        property :hasObject,
          RDF.type           => RDF.Property,
          RDFS.subPropertyOf => BELV1_0.hasChild,
          RDFS.domain        => BELV1_0.Statement,
          RDFS.range         => BELV1_0.Term
        property :hasEvidence,
          RDF.type           => RDF.Property,
          RDFS.domain        => BELV1_0.Statement,
          RDFS.range         => BELV1_0.Evidence

        # Evidence properties
        property :hasAnnotation,
          RDF.type           => RDF.Property,
          RDFS.domain        => BELV1_0.Evidence,
          RDFS.range         => BELV1_0.AnnotationConcept
        property :hasCitation,
          RDF.type           => RDF.Property,
          RDFS.domain        => BELV1_0.Evidence,
          RDFS.range         => RDFS.Resource
        property :hasEvidenceText,
          RDF.type           => RDF.Property,
          RDFS.domain        => BELV1_0.Evidence,
          RDFS.range         => XSD.string
        property :hasStatement,
          RDF.type           => RDF.Property,
          RDFS.domain        => BELV1_0.Evidence,
          RDFS.range         => BELV1_0.Statement

        # BiologicalExpressionLanguage properties
        property :hasBiologicalExpressionLanguage,
          RDF.type           => RDF.Property,
          RDFS.domain        => BELV1_0.Evidence,
          RDFS.range         => BELV1_0.BiologicalExpressionLanguage
        property :hasVersion,
          RDF.type           => RDF.Property,
          RDFS.domain        => BELV1_0.BiologicalExpressionLanguage,
          RDFS.range         => XSD.string
      end
    end
  end
end
