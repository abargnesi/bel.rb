module BEL::Translator::Plugins

  module Jgf

    class Writer
      def write(nanopubs, writer = StringIO.new, options = {})
        graph = {
          :type  => 'BEL-V1.0',
          :nodes => [],
          :edges => []
        }

        nanopubs.each do |nanopub|
          stmt    = nanopub.bel_statement
          subject = stmt.subject.to_s

          graph[:nodes] << {
            :id    => subject,
            :label => subject
          }

          if stmt.object
            object  = stmt.object.to_s
            graph[:nodes] << {
              :id    => object,
              :label => object
            }
            graph[:edges] << {
              :source   => subject,
              :relation => stmt.relationship.to_s(:long),
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
