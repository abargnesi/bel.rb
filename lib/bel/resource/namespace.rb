require_relative '../resource'
require_relative 'namespace_value'

module BEL
  module Resource

    # TODO Document
    class Namespace

      attr_reader :uri

      # TODO Document
      def initialize(rdf_repository, uri)
        @rdf_repository = rdf_repository
        @uri            = uri
        @concept_query  = [
          :predicate => RDF::SKOS.inScheme,
          :object    => @uri
        ]
        @predicates     = @rdf_repository.query(:subject => @uri).
                            each.map(&:predicate)
      end

      # TODO Document
      def each
        return to_enum(:each) unless block_given?
				@rdf_repository.
					query(@concept_query) { |solution|
						yield NamespaceValue.new(@rdf_repository, solution.subject)
					}
      end

      def find(*values)
        return to_enum(:find, *values) unless block_given?

        values.flatten.each do |v|
          yield find_value(v)
				end
			end

      protected

      def find_value(value)
        return nil if value == nil
        vstr  = value.to_s
        return nil if vstr.empty?

				vlit  = RDF::Literal(vstr)
				label = value_query(
					:predicate => RDF::SKOS.prefLabel,
					:object    => vlit
				)
			  return NamespaceValue.new(@rdf_repository, label.subject) if label

				ident = value_query(
					:predicate => RDF::DC.identifier,
					:object    => vlit
				)
				return NamespaceValue.new(@rdf_repository, ident.subject) if ident

				title = value_query(
					:predicate => RDF::DC.title,
					:object    => vlit
				)
				return NamespaceValue.new(@rdf_repository, title.subject) if title
      end

      def value_query(pattern)
				@rdf_repository.query(pattern).find { |solution|
				  @rdf_repository.has_statement?(
						RDF::Statement(solution.subject, RDF::SKOS.inScheme, @uri)
					)
				}
      end

      def method_missing(method)
        method_predicate = @predicates.find { |p|
          p.qname[1].to_sym == method.to_sym
        }
        return nil unless method_predicate
        objects = @rdf_repository.query(
          :subject   => @uri,
          :predicate => method_predicate
        ).each.map(&:object)
        objects.size == 1 ? objects.first : objects.to_a
      end
    end
  end
end
