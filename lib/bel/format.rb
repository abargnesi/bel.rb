module BEL
  module Format

    def self.evidence(input, input_format)
      prepared_input = process_input(input)

      translator = BEL::Extension.system.find { |ext|
        ext.id == input_format.to_sym
      }
      raise %Q{Translator for "#{input_format}" is not available.} unless translator

      EvidenceIterable.new(prepared_input, translator)
    end

    def self.translate(input, input_format, output_format, writer = nil)
      prepared_input = process_input(input)

      in_translator  = BEL::Extension.system.find { |ext|
        ext.id == input_format.to_sym
      }
      out_translator = BEL::Extension.system.find { |ext|
        ext.id == output_format.to_sym
      }

      objects = in_translator.read(prepared_input)
      output = out_translator.write(objects, writer)
    end

    def self.process_input(input)
      if input.respond_to? :read
        input
      elsif File.exist?(input)
        File.open(input, :ext_enc => Encoding::UTF_8)
      elsif input.respond_to? :to_s
        input.to_s
      end
    end
    private_class_method :process_input

    class EvidenceIterable
      include Enumerable

      def initialize(input, translator)
        @input      = input
        @translator = translator
      end

      def each
        if block_given?
          @translator.read(@input).each do |evidence|
            yield evidence
          end
        else
          to_enum(:each)
        end
      end
    end
  end
end
