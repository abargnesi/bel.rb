module BEL::Translator::Plugins

  module Trix

    ID          = :trix
    NAME        = 'TriX RDF Translator'
    DESCRIPTION = 'A translator that can read and write TriX (https://en.wikipedia.org/wiki/TriX_(syntax)) for BEL evidence.'
    MEDIA_TYPES = %i(application/trix)
    EXTENSIONS  = %i(trix)

    def self.create_translator(options = {})
      require 'rdf'
      require 'rdf/trix'
      require_relative 'rdf/translator'
      BEL::Translator::Plugins::Rdf::RdfTranslator.new(
        ID,
        options[:write_schema]
      )
    end

    def self.id
      ID
    end

    def self.name
      NAME
    end

    def self.description
      DESCRIPTION
    end

    def self.media_types
      MEDIA_TYPES
    end 

    def self.file_extensions
      EXTENSIONS
    end
  end
end
