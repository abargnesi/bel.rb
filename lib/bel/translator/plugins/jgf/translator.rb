require_relative 'reader'
require_relative 'writer'

module BEL::Translator::Plugins

  module Jgf

    class JgfTranslator
      include ::BEL::Translator

      def read(data, options = {})
        Reader.new.read(data, options)
      end

      def write(nanopubs, writer = StringIO.new, options = {})
        Writer.new.write(nanopubs, writer, options)
      end
    end
  end
end
