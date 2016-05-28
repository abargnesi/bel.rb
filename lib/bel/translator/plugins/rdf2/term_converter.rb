require          'rdf'
require          'bel_parser/language/version2_0'
require_relative 'belv2_0'
require_relative 'rdf_converter'

module BEL
  module BELRDF
    class TermConverter
      include BELParser::Language::Version2_0::Functions
      include RDFConverter

      def initialize(parameter_converter)
        @parameter_converter = parameter_converter
      end

      # Convert a {BELParser::Expression::Model::Term} to {RDF::Graph} of
      # RDF statements.
      #
      # @param  [BELParser::Expression::Model::Term] term
      # @return [RDF::Graph] graph of RDF statements representing the term
      def convert(term)
        path_part     = to_path_part(term)
        term_uri      = to_uri(path_part)
        tg            = RDF::Graph.new
        tg           << s(term_uri, RDF.type, BELV2_0.Term)

        term_class = FUNCTION_HASH[term.function]
        if term_class
          tg << s(term_uri, RDF.type, term_class)
        end

        term.arguments.each do |arg|
          case arg
          when BELParser::Expression::Model::Parameter
            param_uri, paramg = @parameter_converter.convert(arg)
            if param_uri
              tg << paramg
              tg << s(term_uri, BELV2_0.hasConcept, param_uri)
            end
          when BELParser::Expression::Model::Term
            path_part, iterm_uri, itermg = convert(arg)
            tg << itermg
            tg << s(term_uri, BELV2_0.hasChild, iterm_uri)
          end
        end

        [path_part, term_uri, tg]
      end

      private

      def to_path_part(term)
        return '' if term.nil?
        term
          .to_s
          .squeeze(')')
          .gsub(/[")\[\]]/, '')
          .gsub(/[(:, ]/, '_')
      end

      def to_uri(path_part)
        BELR[URI::encode(path_part)]
      end

      FUNCTION_HASH = {
        Abundance => BELV2_0.Abundance,
        Activity  => BELV2_0.Activity,
        BiologicalProcess => BELV2_0.BiologicalProcess,
        CellSecretion => BELV2_0.CellSecretion,
        CellSurfaceExpression => BELV2_0.CellSurfaceExpression,
        ComplexAbundance => BELV2_0.ComplexAbundance,
        CompositeAbundance => BELV2_0.CompositeAbundance,
        Degradation => BELV2_0.Degradation,
        #Fragment => # TODO Special
        #FromLocation => # TODO Special
        Fusion => BELV2_0.FusionAbundance,
        GeneAbundance => BELV2_0.GeneAbundance,
        #List => # TODO Ignore or expand.
        #Location => # TODO Special
        MicroRNAAbundance => BELV2_0.MicroRNAAbundance,
        #MolecularActivity => # TODO Special
        Pathology => BELV2_0.Pathology,
        #Products => # TODO Special
        ProteinAbundance => BELV2_0.ProteinAbundance,
        #ProteinModification => # TODO Special, consider Protein and ProteinModification.
        #Reactants => # TODO Special
        Reaction => BELV2_0.Reaction,
        RNAAbundance => BELV2_0.RNAAbundance,
        #ToLocation => # TODO Special
        Translocation => BELV2_0.Translocation,
        #Variant => # TODO Special
      }.freeze
    end
  end
end
