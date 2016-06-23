require 'bel'
require_relative '../gen'
BEL::Gen.soft_require('rantly')

module BEL
  module Gen

    # The {Statement} module defines methods that generate random BEL
    # {BEL::Nanopub::Statement statements}.
    module Statement
      include BEL::Gen::Term

      # Array of all BEL 1.0 relationships including both short and long form.
      RELATIONSHIPS = BEL::Language::RELATIONSHIPS.each.to_a.flatten.sort.uniq

      # Returns a randomly chosen relationship.
      # @return [Symbol] the relationship label (short or long form)
      def relationship
        Rantly {
          choose(*RELATIONSHIPS)
        }
      end

      # Returns a randomly constructed BEL statement.
      # @return [String] the statement label
      def bel_statement
        observed = observed_term
        simple   = simple_statement
        nested   = nested_statement

        Rantly {
          freq(
            [5, :literal, simple],
            [1, :literal, observed],
            [0, :literal, nested]
          )
        }
      end

      def observed_term
        "#{bel_term}"
      end

      def simple_statement
        "#{bel_term} #{relationship} #{bel_term}"
      end

      def nested_statement
        "#{bel_term} #{relationship} (#{simple_statement})"
      end
    end
  end
end
