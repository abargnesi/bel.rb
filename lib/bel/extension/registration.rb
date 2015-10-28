module BEL::Extension

  module Registration

    # Registers the +translator+ object as available to callers. The
    # +translator+ should respond to the methods defined in the
    # {Translator::Translator} module.
    #
    # @param  [Translator::Translator] translator the translator to register
    # @return [Translator::Translator] the +translator+ parameter is returned
    #         for convenience
    def register(extension)
      mutex.synchronize {
        @extensions ||= []
        @index      ||= _autovivified_hash(_autovivified_hash([]))

        if !extension.respond_to?(:id)
          raise %Q{#{extension.class} must respond to the "id" method with an ID.}
        end

        if self.any?{ |other| extension.id == other.id }
          raise ExtensionRegistrationError.new(extension.id)
        end

        # track registered extensions
        @extensions << extension

        # index extension by its id
        @index[:id][_symbolize(extension.id)] << extension

        extension
      }
    end

    def _autovivified_hash(value = :self)
      if value == :self
        Hash.new do |h, k|
          h[k] = Hash.new(&h.default_proc)
        end
      else
        Hash.new do |h, k|
          h[k] = value
        end
      end
    end
    private :_autovivified_hash

    def _symbolize(key)
      key.to_s.to_sym
    end
    private :_symbolize

    # TODO Document
    class ExtensionConflictByIdError < StandardError

      attr_reader :existing_extension
      attr_reader :new_extension

      def initialize(new_extension, existing_extension)
        super(
          %Q{
            Error registering extension "#{new_extension.name}".
            The id clashed with existing extension
            "#{existing_extension.name}".
          }.gsub(/\s+/, ' ')
        )
        @new_extension      = new_extension
        @existing_extension = existing_extension
      end
    end
  end
end
