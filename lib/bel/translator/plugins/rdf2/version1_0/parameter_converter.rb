require          'rdf'
require_relative 'belv1_0'
require_relative 'rdf_converter'

module BEL
  module BELRDF
    module Version1_0
      class ParameterConverter
        include RDFConverter

        def initialize(namespace_converter)
          @namespace_converter = namespace_converter
        end
        # Convert a {BELParser::Expression::Model::Parameter} to {RDF::Graph} of
        # RDF statements.
        #
        # @param  [BELParser::Expression::Model::Parameter] parameter
        # @return [RDF::Graph] graph of RDF statements representing the parameter
        def convert(parameter)
          namespace_vocab = @namespace_converter.convert(parameter.namespace)
          return nil unless namespace_vocab

          value_s       = parameter.value.to_s
          param_uri     = namespace_vocab[value_s]
          pg            = RDF::Graph.new
          if parameter.encoding
            parameter.encoding.each do |enc|
              concept_type = ENCODING_HASH[enc]
              next unless concept_type
              pg << s(param_uri, RDF.type, concept_type)
            end
          end
          [param_uri, pg]
        end

        ENCODING_HASH = {
          :A => BELV1_0.AbundanceConcept,
          :B => BELV1_0.BiologicalProcessConcept,
          :C => BELV1_0.ComplexConcept,
          :E => BELV1_0.ProteinModificationConcept,
          :G => BELV1_0.GeneConcept,
          :L => BELV1_0.LocationConcept,
          :M => BELV1_0.MicroRNAConcept,
          :O => BELV1_0.PathologyConcept,
          :P => BELV1_0.ProteinConcept,
          :R => BELV1_0.RNAConcept,
          :T => BELV1_0.MolecularActivityConcept
        }.freeze
      end
    end
  end
end
