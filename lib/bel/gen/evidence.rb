require 'bel'
require_relative 'document_header'
require_relative 'annotation'
require_relative 'citation'
require_relative 'namespace'
require_relative 'parameter'
require_relative 'term'
require_relative 'statement'

require_relative '../gen'
BEL::Gen.soft_require('rantly')

module BEL
  module Gen

    # The {Evidence} module defines methods that generate random
    # {BEL::Nanopub::Evidence evidence}.
    module Evidence

      # Include other generators needed to create {BEL::Nanopub::Evidence}.
      include BEL::Gen::DocumentHeader
      include BEL::Gen::Annotation
      include BEL::Gen::Citation
      include BEL::Gen::Namespace
      include BEL::Gen::Parameter
      include BEL::Gen::Statement
      include BEL::Gen::Term

      # Returns a random {BEL::Nanopub::Evidence}.
      #
      # @return [BEL::Nanopub::Evidence] a random evidence
      def evidence
        evidence = BEL::Nanopub::Evidence.new

        evidence.bel_statement      = bel_statement
        evidence.citation           = citation
        evidence.summary_text       = BEL::Nanopub::SummaryText.new(
          Rantly { sized(120) {string(:alpha)} }
        )
        evidence.experiment_context = BEL::Nanopub::ExperimentContext.new(
          (1..5).to_a.sample.times.map { annotation }
        )
        evidence.references         = BEL::Nanopub::References.new({
          :namespaces  => referenced_namespaces.map { |prefix, ns_def|
            {
              :keyword => prefix,
              :uri     => ns_def.url
            }
          }.sort_by { |ns| ns[:keyword] },
          :annotations => referenced_annotations.map { |keyword, anno_def|
            {
              :keyword => keyword,
              :type    => :uri,
              :domain  => anno_def.url
            }
          }
        })
        evidence.metadata           = BEL::Nanopub::Metadata.new({
          :document_header => document_header
        })

        evidence
      end
    end
  end
end
