require 'rdf'

module BEL
  module Resource

    class BELV < RDF::StrictVocabulary('http://www.openbel.org/vocabulary/')
      term     :NamespaceConceptScheme

      property :prefix
      property :domain
      property :species
      property :inScheme
      property :orthologousMatch
    end
  end
end

require_relative 'resource/namespaces'
require_relative 'resource/namespace'
require_relative 'resource/namespace_value'
