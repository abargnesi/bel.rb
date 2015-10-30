require_relative 'evidence_yielder'
require_relative 'bel_yielder'

module BEL::Extension

  module BEL

    class BELTranslator

      include ::BEL::Extension::Descriptor
      include ::BEL::Extension::Translator

      ID          = :bel
      NAME        = 'BEL Script Translator'
      DESCRIPTION = 'A translator that can read and write evidence to BEL Script (version 1.0).'
      MEDIA_TYPES = %i(application/bel)
      EXTENSIONS  = %i(bel)
      
      def id
        ID
      end

      def name
        NAME
      end

      def description
        DESCRIPTION
      end

      def media_types
        MEDIA_TYPES
      end

      def file_extensions
        EXTENSIONS
      end

      def read(data, options = {})
        EvidenceYielder.new(data)
      end

      def write(objects, writer = StringIO.new, options = {})
        BELYielder.new(objects).each { |bel_part|
          writer << "#{bel_part}"
          writer.flush
        }
      end
    end
  end

  register(BEL::BELTranslator.new)
end
