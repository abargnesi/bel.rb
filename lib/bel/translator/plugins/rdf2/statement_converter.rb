require          'rdf'
require_relative 'rdf_converter'

module BEL
  module BELRDF
    class StatementConverter
      include RDFConverter

      def initialize(term_converter)
        @term_converter = term_converter
      end

      # Convert a {BELParser::Expression::Model::Statement} to {RDF::Graph} of
      # RDF statements.
      #
      # @param  [BELParser::Expression::Model::Statement] bel_statement
      # @return [RDF::Graph] graph of RDF statements representing the statement
      def convert(bel_statement)
        # Dive into subject
        sub_part, subg = @term_converter.convert(bel_statement.subject)

        # Dive into object
        case
        when bel_statement.simple?
          obj_part, objg = @term_converter.convert(bel_statement.object)
          rel_part       = nil
          obj_uri        = objg.graph_name
          path_part      = "#{sub_part}_#{rel_part}_#{obj_part}"
          stmt_uri       = BELR[URI::encode(path_part)]

          sg            = RDF::Graph.new
          sg.graph_name = stmt_uri
          sg << subg
          sg << objg
          sg << s(stmt_uri, BELV2_0.hasSubject, subg.graph_name)
          sg << s(stmt_uri, BELV2_0.hasObject,  objg.graph_name)
        when bel_statement.nested?
          obj_part, objg = convert(bel_statement.object)
          rel_part       = nil
          obj_uri        = objg.graph_name
          path_part      = "#{sub_part}_#{rel_part}_#{obj_part}"
          stmt_uri       = BELR[URI::encode(path_part)]

          sg            = RDF::Graph.new
          sg.graph_name = stmt_uri
          sg << subg
          sg << objg
          sg << s(stmt_uri, BELV2_0.hasSubject, subg.graph_name)
          sg << s(stmt_uri, BELV2_0.hasObject,  objg.graph_name)
        else
          path_part      = sub_part
          stmt_uri       = BELR[URI::encode(path_part)]

          sg            = RDF::Graph.new
          sg.graph_name = stmt_uri
          sg << s(stmt_uri, BELV2_0.hasSubject, subg.graph_name)
        end

        [path_part, sg]
      end
    end
  end
end
