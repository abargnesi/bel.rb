module BEL
  module Extension

    # The {Translator} module defines a framework for adding new document
    # translations.
    # This is useful when reading, writing, and {BEL::Translation translating}
    # BEL data.
    #
    # A {Translator} extension is defined and registered in the following steps:
    #
    # - Create a ruby source file located under +bel/extensions/translator/+ on the
    #   +$LOAD_PATH+.
    # - Within the file, create a class that implements the protocol specified
    #   by {Translator::Translator}.
    # - Instantiate and register your translator extension by calling
    #   {Translator.register}.
    #
    # To see how to define a new translator extension have a look at the
    # {Translator::Translator} module.
    #
    module Translator

      FORMATTER_MUTEX = Mutex.new
      private_constant :FORMATTER_MUTEX

      # Registers the +translator+ object as available to callers. The
      # +translator+ should respond to the methods defined in the
      # {Translator::Translator} module.
      #
      # @param  [Translator::Translator] translator the translator to register
      # @return [Translator::Translator] the +translator+ parameter is returned
      #         for convenience
      def self.register(translator)
        FORMATTER_MUTEX.synchronize {
          @@translators ||= []
          # vivified hash, like: { :foo => { :bar => [] } }
          @@index ||= (
            Hash.new do |h0, k0|
              h0[k0] = Hash.new do |h1, k1|
                h1[k1] = []
              end
            end
          )
          
          if _translators(translator.id)
#            raise ExtensionRegistrationError.new(translator.id)
          end

          # track registered translators
          @@translators << translator

          # index translator by its id
          @@index[:id][symbolize(translator.id)] << translator

          # index translator by one or more file extensions
          [translator.file_extensions].flatten.compact.to_a.each do |file_ext|
            @@index[:file_extension][symbolize(file_ext)] << translator
          end

          # index translator by one or more media types
          [translator.media_types].flatten.compact.to_a.each do |media_type|
            @@index[:media_type][symbolize(media_type)] << translator
          end

          translator
        }
      end

      # Returns the {Translator::Translator translators} found for the +values+
      # splat. The returned matches have the same cardinality as the +values+
      # splat to allow destructuring.
      #
      # @example Retrieve a single translator by id.
      #   bel_translator  = Format.translators(:bel)
      # @example Retrieve a single translator by file extension.
      #   xbel_translator = Format.translators(:xml)
      # @example Retrieve a single translator by media type.
      #   json_translator = Format.translators(%s(application/json))
      # @example Retrieve multiple translators using mixed values.
      #   belf, xbelf, jsonf = Format.translators(:bel, :xml, "application/json")
      #
      # @param  [Array<#to_s>] values the splat that identifies translators
      # @return [Translator::Translator Array<Translator::Translator>] for each
      #         consecutive value in the +values+ splat; if the +values+ splat
      #         contains one value then a single translator reference is returned
      #         (e.g. not an Array)
      def self.translators(*values)
        FORMATTER_MUTEX.synchronize {
          _translators(*values)
        }
      end

      def self._translators(*values)
        if values.empty?
          Array.new @@translators
        else
          index = (@@index ||= {})
          matches = values.map { |value|
            value = symbolize(value)
            @@index.values_at(:id, :file_extension, :media_type).
              compact.
              inject([]) { |result, coll|
                if coll.has_key?(value)
                  result.concat(coll[value])
                end
                result
              }.uniq.first
          }
          matches.size == 1 ? matches.first : matches
        end
      end
      private_class_method :_translators

      def self.symbolize(key)
        key.to_s.to_sym
      end
      private_class_method :symbolize

      # The Translator module defines methods to be implemented by a translator
      # extension +Class+. It is broken up into three parts:
      #
      # - Metadata
      #   - {#id}:              the runtime-wide unique extension id
      #   - {#media_types}:     the media types this translator supports
      #   - {#file_extensions}: the file extensions this translator supports
      # - Deserialize
      #   - {#deserialize}:     read the implemented document translator and
      #     return {::BEL::Model::Evidence} objects
      # - Serialize
      #   - {#serialize}:       write {::BEL::Model::Evidence} objects to the
      #     implemented translator
      #
      # @example Typical creation of a {Translator} class.
      #   class FormatYAML
      #     include BEL::Extension::Translator::Translator
      #     # override methods
      #   end
      #
      # @example Create a YAML translator extension.
      #   class FormatYAML
      #     include BEL::Extension::Translator::Translator
      #
      #     ID          = :yaml
      #     MEDIA_TYPES = %i(text/yaml)
      #     EXTENSIONS  = %i(yaml)
      #
      #     def id
      #       ID
      #     end
      #
      #     def media_types
      #       MEDIA_TYPES
      #     end
      #
      #     def file_extensions
      #       EXTENSIONS
      #     end
      #
      #     def deserialize(data)
      #       YAML.load(data)
      #     end
      #
      #     def serialize(data)
      #       YAML.dump(data)
      #     end
      #   end
      module Translator

        def id
          raise NotImplementedError.new("#{__method__} is not implemented.")
        end

        def name
          raise NotImplementedError.new("#{__method__} is not implemented.")
        end

        def description
          raise NotImplementedError.new("#{__method__} is not implemented.")
        end

        def media_types
          # optional
          nil
        end

        def file_extensions
          # optional
          nil
        end

        def evidence_hash(object)
          raise NotImplementedError.new("#{__method__} is not implemented.")
        end

        def deserialize(data)
          raise NotImplementedError.new("#{__method__} is not implemented.")
        end

        def serialize(data, writer = nil)
          raise NotImplementedError.new("#{__method__} is not implemented.")
        end
      end

      # TranslatorError represents an error when the specified translator is
      # not supported by the {Translator} extension framework.
      class TranslatorError < StandardError

        TRANSLATOR_ERROR = %Q{Translator for "%s" is not supported.}

        def initialize(translator)
          super(TRANSLATOR_ERROR % translator)
        end
      end
    end
  end
end
