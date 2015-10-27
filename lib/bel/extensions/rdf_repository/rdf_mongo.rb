require 'bel'

begin
  require 'rdf/mongo'
rescue LoadError => e
  # Raise LoadError if the requirements were not met.
  raise
end

module BEL::Extension::RdfRepository

  class RdfMongo

    include BEL::Extension::RdfRepository::Factory

    ID = :rdf_mongo

    # TODO Document
    def id
      ID
    end

    # TODO Document
    # TODO Capture options in detail with examples.
    def create_repository(options = {})
      RDF::Mongo::Repository.new(options)
    end
  end

  register_rdf_repository(RdfMongo.new)
end
