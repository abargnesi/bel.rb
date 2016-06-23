module BEL::Translator::Plugins

  module Jgf

    class Writer
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
    end
  end
end
