require 'bel_parser/language'
require 'set'

module BEL::Translator::Plugins

  module Jgf

    class Writer
      include ::BELParser::Expression::Model

      def write(nanopubs, writer = StringIO.new, options = {})
        index = index_nanopubs(nanopubs)

        edges = []
        edges.concat(index[:simple_statement].map { |k, v| simple_to_edge(k, v) })
        edges.concat(index[:nested_statement].map { |k, v| nested_to_edge(k, v) })

        nodes = Set.new
        nodes.merge(index[:observed_term].map { |k, v| observed_to_node(k, v) })
        nodes.merge(edge_nodes(edges))

        graph = first_nanopub_to_graph(index)
        graph.merge!({ :nodes => nodes.to_a, :edges => edges.to_a })
        ::BEL::JSON.write({:graph => graph}, writer, options)
        writer
      end

      private

      def index_nanopubs(nanopubs)
        # Autovivify of the form: { :key1 => { :key2 => [] } }
        index = Hash.new do |type_hash, key|
          type_hash[key] = Hash.new do |edge_hash, key|
            edge_hash[key] = []
          end
        end

        nanopubs.each.reduce(index) do |index, nanopub|
          statement = nanopub.bel_statement
          unless statement.nil?
            index[statement.type][statement_key(statement)] << nanopub
          end
          index
        end
      end

      def statement_key(statement)
        case statement.type
        when :observed_term
          [statement.subject]
        when :simple_statement
          [statement.subject, statement.relationship, statement.object]
        when :nested_statement
          # Indexes a nested statement by its innermost simpel statement
          # thereby only supporting simple edges. The original nested
          # statement nanopub will be including in edge metadata.
          while statement.type == :nested_statement do
            statement = statement.object
          end
          [statement.subject, statement.relationship, statement.object]
        end
      end

      def observed_to_node(edge_id, nanopubs)
        id = edge_id.map { |part| part.to_s(:long) }.join(' ')
        {:id => id, :label => id}
      end

      def simple_to_edge(edge_id, nanopubs)
        source, relation, target = edge_id.map { |part| part.to_s(:long) }
        {
          :source   => source,
          :target   => target,
          :relation => relation,
          :directed => edge_id[1].directed?,
          :label    => "#{source} #{relation} #{target}",
          :metadata => {
            :causal   => edge_id[1].causal?,
            :nanopubs =>
              nanopubs.map do |nanopub|
                hash = nanopub.to_h
                hash[:bel_statement] = hash[:bel_statement].to_s(:long)
                hash
              end
          }
        }
      end
      alias :nested_to_edge :simple_to_edge

      def edge_nodes(edges)
        edges.flat_map do |edge|
          edge.values_at(:source, :target).map do |node|
            {
              :id    => node,
              :label => node
            }
          end
        end
      end

      def first_nanopub_to_graph(index)
        graph = {:metadata => {}}
        if nanopub = first_nanopub(index)
          header      = nanopub.metadata.document_header
          bel_version =
            nanopub.metadata.bel_version || BELParser::Language.default_version

          graph[:label]                  = header[:Name]
          graph[:metadata][:description] = header[:Description]
          graph[:metadata][:version]     = header[:Version]
          graph[:metadata][:bel_version] = bel_version
        end

        graph
      end

      def first_nanopub(index)
        index.each do |type, indexed_nanopubs|
          indexed_nanopubs.each do |edge_id, nanopubs|
            return nanopubs.first unless nanopubs.empty?
          end
        end
      end
    end
  end
end
