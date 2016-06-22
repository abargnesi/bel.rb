require 'bel'
require 'bel/json'
require 'bel_parser/expression/parser'

module BEL::Translator::Plugins

  module Jgf

    class JgfTranslator

      include ::BEL::Translator
      include ::BEL::Namespace
      include ::BEL::Nanopub
      include ::BELParser::Expression::Model

      def read(data, options = {})
        ::BEL::JSON.read(data, options).lazy.select { |obj|
          obj.include?(:nodes)
        }.flat_map { |graph|
          unwrap(graph)
        }
      end

      def write(objects, writer = StringIO.new, options = {})
        graph = {
          :type  => 'BEL-V1.0',
          :nodes => [],
          :edges => []
        }

        objects.each do |nanopub|
          unless nanopub.bel_statement.is_a?(Statement)
            nanopub.bel_statement = Nanopub.parse_statement(nanopub)
          end

          stmt    = nanopub.bel_statement
          subject = stmt.subject.to_bel

          graph[:nodes] << {
            :id    => subject,
            :label => subject
          }

          if stmt.object
            object  = stmt.object.to_bel
            graph[:nodes] << {
              :id    => object,
              :label => object
            }
            graph[:edges] << {
              :source   => subject,
              :relation => stmt.relationship,
              :target   => object
            }
          end
        end
        graph[:nodes].uniq!

        ::BEL::JSON.write({:graph => graph}, writer, options)
        writer
      end

      private

      def unwrap(graph)
        res_index  = ResourceIndex.openbel_published_index('20150611')
        namespaces = namespaces(res_index)

        nanopub        = build_default_nanobub_hash(graph, res_index)
        bel_version    = nanopub[:metadata][:bel_version]
        spec =
          if BELParser::Language.defines_version?(bel_version)
            BELParser::Language.specification(bel_version)
          else
            BELParser::Language.default_specification
          end

        nodes    = graph.fetch(:nodes, [])
        node_ids = compute_node_id_hash(nodes)
        edges    = graph.fetch(:edges, [])

        node_nanopubs(nanopub, node_ids, edges) +
        edge_nanopubs(nanopub, node_ids, edges)
      end

      def node_nanopubs(nanopub, node_ids, edges)
        ids = node_ids.keys.to_set
        edges.each do |edge|
          src, rel, tgt = edge.values_at(:source, :relation, :target)
          source_node = node_ids[src]
          target_node = node_ids[tgt]
          next unless source_node && target_node

          ids.delete(source_node)
          ids.delete(target_node)
        end

        ids.map do |id|
          Nanopub.create(
            :bel_statement => "#{node_ids[id]}\n",
            :metadata      => nanopub[:metadata],
            :references    => nanopub[:references]
          )
        end
      end

      def edge_nanopubs(default_nanopub, node_ids, edges)
        edges.flat_map do |edge|
          src, tgt = edge.values_at(:source, :target)
          source_node = node_ids[src]
          target_node = node_ids[tgt]
          next unless source_node && target_node

          edge_metadata = edge.fetch(:metadata, {})
          nanopubs      = edge_metadata[:nanopubs] || edge_metadata[:evidences]

          if nanopubs.empty?
            rel = edge.fetch(:relation, 'association')
            Nanopub.create(
              :bel_statement => "#{source_node} #{rel} #{target_node}\n",
              :metadata      => default_nanopub[:metadata],
              :references    => default_nanopub[:references]
            )
          else
            nanopubs.map do |edge_nanopub|
              convert_edge_nanopub(edge_nanopub, default_nanopub)
            end
          end
        end.compact
      end

      def convert_edge_nanopub(nanopub, default_nanopub)
        exp_context = nanopub[:experiment_context] || nanopub[:biological_context]
        if exp_context.is_a?(Hash)
          exp_context = 
            exp_context.map do |keyword, value|
              {
                :name  => keyword,
                :value => value
              }
            end
        end

        Nanopub.create(
          :bel_statement      => nanopub[:bel_statement],
          :citation           => nanopub[:citation],
          :support            => nanopub[:support] || nanopub[:summary_text],
          :experiment_context => exp_context,
          :metadata           =>
            default_nanopub[:metadata].merge(nanopub.fetch(:metadata, {})),
          :references         =>
            default_nanopub[:references].merge(nanopub.fetch(:references, {}))
        )
      end

      def build_default_nanobub_hash(graph, res_index)
        graph_metadata     = graph.fetch(:metadata, {})
        metadata           = Metadata.new
        references         = References.new

        metadata.document_header[:Name]        = graph.fetch(:label, 'BEL graph')
        metadata.document_header[:Description] = graph_metadata.fetch(:description, '')
        metadata.document_header[:Version]     = graph_metadata.fetch(:version, '1.0')
        metadata.bel_version = graph_metadata.fetch(:bel_version, '1.0')

        if graph_metadata.key?(:ncbi_tax_id)
          # TODO Add to experiment context and references.
        end

        references.annotations =
          res_index.annotations.sort_by { |anno|
            anno.keyword
          }.map { |anno|
            {
              :keyword => anno.keyword,
              :type    => anno.type,
              :domain  => anno.domain
            }
          }
        references.namespaces =
          res_index.namespaces.sort_by { |ns|
            ns.keyword
          }.map { |ns|
            {
              :keyword => ns.keyword,
              :type    => :url,
              :domain  => ns.url
            }
          }

        {
          :bel_statement      => nil,
          :citation           => nil,
          :support            => nil,
          :experiment_context => nil,
          :references         => references.values,
          :metadata           => metadata.values
        }
      end

      def compute_node_id_hash(nodes)
        Hash[
          nodes.map do |node|
            [node[:id], (node[:label] || node[:id])]
          end
        ]
      end

      def namespaces(resource_index)
        Hash[
          resource_index.namespaces.sort_by { |ns|
            ns.keyword
          }.map { |ns|
            keyword = ns.keyword.to_s
            [keyword, Namespace.new(keyword, nil, ns.url)]
          }
        ]
      end
    end
  end
end
