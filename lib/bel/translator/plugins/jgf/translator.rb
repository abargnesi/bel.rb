require_relative 'reader'
require_relative 'writer'

module BEL::Translator::Plugins

  module Jgf

    class JgfTranslator
      include ::BEL::Translator

      def read(data, options = {})
        Reader.new.read(data, options)
      end

      def write(objects, writer = StringIO.new, options = {})
        Writer.new.write(objects, writer, options)
      end
    end
  end
end
