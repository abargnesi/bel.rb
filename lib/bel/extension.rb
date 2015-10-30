require_relative 'extension/registration'
require_relative 'extension/query'

module BEL

  # The {Extension} module defines specific areas of customization within the
  # *bel* gem:
  #
  # - Document translation: see {BEL::Extension::Translation}
  module Extension

    def self.system
      @instance ||= Instance.new
    end

    def self.register(extension)
      self.system.register(extension)
    end

    class Instance

      include Registration
      include Query

      TYPES = {
        :rdf_repository => 'bel/extensions/rdf_repository/**/ext.rb',
        :translator     => 'bel/extensions/translator/**/ext.rb'
      }
      private_constant :TYPES

      def extension_types
        TYPES.keys
      end

      def extension_path_glob(type)
        TYPES[type.to_sym]
      end

      private

      def self._type_for(extension)
        return :translator     if extension.class.include?(Translator)
        return :rdf_repository if extension.class.include?(RdfRepository)
      end
      private_class_method :_type_for
    end

    # TODO Document
    module Descriptor

      def id
        raise NotImplementedError.new("#{__method__} is not implemented.")
      end

      def name
        raise NotImplementedError.new("#{__method__} is not implemented.")
      end

      def description
        raise NotImplementedError.new("#{__method__} is not implemented.")
      end
    end

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

      def media_types
        # optional
        nil
      end

      def file_extensions
        # optional
        nil
      end

      def read(data)
        raise NotImplementedError.new("#{__method__} is not implemented.")
      end

      def write(data, writer = nil)
        raise NotImplementedError.new("#{__method__} is not implemented.")
      end
    end

    # TODO Document
    module RdfRepository

      def create_repository(options = {})
        raise NotImplementedError.new("#{__method__} is not implemented.")
      end
    end
  end
end
