module BEL::Translator::Plugins

  module Csv

    ID          = :csv
    NAME        = 'CSV Translator'
    DESCRIPTION = 'A translator that can read and write CSV for BEL evidence.'
    MEDIA_TYPES = %i(text/csv)
    EXTENSIONS  = %i(csv)

    def self.create_translator(options = {})
      require 'csv'
      Translator.new
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

    class Translator

      include ::BEL::Translator

      FORMAT_OPTIONS = {
        :col_sep     => ',',
        :row_sep     => "\n",
        :quote_char  => '"',
        :skip_blanks => true,
        :skip_lines  => /^#.*/
      }

      STATIC_HEADER = %w(
        CitationType CitationId CitationName
        CitationDate CitationAuthors CitationComment
        BELStatement
      )

      ANNOTATIONS = Hash[
        BEL::Annotation::ANNOTATION_LATEST.map { |keyword, (url, rdf_uri)|
          [keyword, url]
        }.sort_by { |(keyword, _)|
          keyword
        }
      ]

      NAMESPACES = Hash[
        BEL::Namespace::NAMESPACE_LATEST.map { |keyword, (url, rdf_uri)|
          [keyword, url]
        }.sort_by { |(keyword, _)|
          keyword
        }
      ]

      def read(data, options = {})
      end

      def write(objects, writer = StringIO.new, options = {})
        options = {
          :use_default_headers => true,
          :experiment_context  => [:Anatomy, :Species, :Tissue],
          :metadata            => [:Creator, :Status, :TextMining]
        }.merge(options)

        writer << CSV.generate_line(header_columns, FORMAT_OPTIONS)
        CSV(writer, FORMAT_OPTIONS) { |csv|
          objects.each do |evidence|
            csv << evidence_columns(evidence)
          end
        }

        writer
      end

      private

      def header_columns
        static_header_columns + dynamic_header_columns
      end

      def static_header_columns
        STATIC_HEADER
      end

      def dynamic_header_columns
        [
          ANNOTATIONS.keys.map { |k| "ExperimentContext:#{k}"     },
#          %w(Metadata:Creator Metadata:Status Metadata:TextMining),
#          NAMESPACES.keys.map  { |k| "References:Namespace:#{k}"  },
#          ANNOTATIONS.keys.map { |k| "References:Annotation:#{k}" },
        ].flatten
      end

      def evidence_columns(evidence)
        columns = []
        columns.concat(citation_columns(evidence))
        columns.concat(bel_statement_columns(evidence))
        columns.concat(experiment_context(evidence))
        columns
      end

      def citation_columns(evidence)
        evidence.citation.to_a
      end

      def bel_statement_columns(evidence)
        [evidence.bel_statement.to_s]
      end

      def experiment_context(evidence)
        # sort and flatten name/value pairs to hash
        evidence_annotations = Hash[
          evidence.experiment_context.values.
          sort_by! { |item|
            item[:name]
          }.map { |item|
            [item[:name], item[:value]]
          }
        ]

        # only keep key, value if the annotation is a dynamic header
        evidence_annotations.keep_if { |k, _| ANNOTATIONS[k] }

        # nil out annotation columns and merge evidence annotations
        Hash[ANNOTATIONS.dup.map { |k, v| [k, nil] }].merge(
          evidence_annotations
        ).values
      end
    end
  end
end
