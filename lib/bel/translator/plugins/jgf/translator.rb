require 'bel'
require 'bel/json'
require 'bel_parser/expression/parser'

module BEL::Translator::Plugins

  module Jgf

    class JgfTranslator

      include ::BEL::Translator
      include ::BEL::Namespace

      def read(data, options = {})
        # FIXME Use default resources only if edge nanopubs do not contain
        # references.
        default_resource_index = options.fetch(:default_resource_index) {
          ResourceIndex.openbel_published_index('20150611')
        }

        ::BEL::JSON.read(data, options).lazy.select { |obj|
          obj.include?(:nodes) && obj.include?(:edges)
        }.flat_map { |graph|
          unwrap(graph, default_resource_index)
        }
      end

      def write(objects, writer = StringIO.new, options = {})
        graph = {
          :type  => 'BEL-V1.0',
          :nodes => [],
          :edges => []
        }

        objects.each do |nanopub|
          unless nanopub.bel_statement.is_a?(BELParser::Expression::Model::Statement)
            nanopub.bel_statement = ::BEL::Nanopub::Nanopub.parse_statement(nanopub)
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

      def unwrap(graph, default_resource_index)
        # index nodes
        id_nodes = Hash[
          graph[:nodes].map { |node|
            [node[:id], (node[:label] || node[:id])]
          }
        ]
        ids = id_nodes.keys.to_set

        # map edges to statements
        bel_statements = graph[:edges].map { |edge|
          src, rel, tgt = edge.values_at(:source, :relation, :target)
          source_node = id_nodes[src]
          target_node = id_nodes[tgt]

          if !source_node || !target_node
            nil
          else
            ids.delete(source_node)
            ids.delete(target_node)

            # semantic default
            rel = 'association' unless rel

            BELParser::Expression.parse_statements(
              "#{source_node} #{rel} #{target_node}\n")
          end
        }.compact

        # map island nodes to bel statements
        if !ids.empty?
          bel_statements.concat(
            ids.map { |id|
              BELParser::Expression.parse_statements(
                "#{id_nodes[id]}\n")
            }
          )
        end

        # map statements to nanopub objects
        bel_statements.map { |bel_statement|
          graph_name  = graph[:label] || graph[:id] || 'BEL Graph'
          bel_version = graph[:metadata][:bel_version] || '1.0'
          metadata    = ::BEL::Nanopub::Metadata.new
          references  = ::BEL::Nanopub::References.new

          # set document header
          metadata.document_header[:Name]        = graph_name
          metadata.document_header[:Description] = graph_name
          metadata.document_header[:Version]     = '1.0'

          # set bel version
          metadata.bel_version = bel_version

          # set annotation definitions
          annotations = graph.fetch(:metadata, {}).
                              fetch(:annotation_definitions, nil)
          if !annotations && default_resource_index
            references.annotations =
              default_resource_index.annotations.sort_by { |anno|
                anno.keyword
              }.map { |anno|
                {
                  :keyword => anno.keyword,
                  :type    => anno.type,
                  :domain  => anno.domain
                }
              }
          end

          # set namespace definitions
          namespaces = graph.fetch(:metadata, {}).
                             fetch(:namespace_definitions, nil)
          if !namespaces && default_resource_index
            references.namespaces =
              default_resource_index.namespaces.sort_by { |ns|
                ns.keyword
              }.map { |ns|
                {
                  :keyword => ns.keyword,
                  :type    => :url,
                  :domain  => ns.url
                }
              }
          end

          ::BEL::Nanopub::Nanopub.create(
            :bel_statement => bel_statement,
            :metadata      => metadata.values,
            :references    => references.values
          )
        }
      end
    end
  end
end
