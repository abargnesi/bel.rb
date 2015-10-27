module BEL
  module Extension

    # TODO Document
    module ResourceRepository

      MUTEX = Mutex.new
      private_constant :MUTEX

      # TODO Document
      def self.register_resource_repository(repo)
        MUTEX.synchronize {
          @@repos ||= []
          # vivified hash, like: { :foo => { :bar => [] } }
          @@index ||= autovivified_hash(autovivified_hash([]))
          
          if _resource_repositories(repo.id)
            raise ExtensionRegistrationError.new(repo.id)
          end

          # track registered formatters
          @@repos << repo

          # index formatter by its id
          @@index[:id][symbolize(repo.id)] << repo

          repo
        }
      end

      # TODO Document
      def self.resource_repositories(*values)
        MUTEX.synchronize {
          _resource_repositories(*values)
        }
      end

      # TODO Document
      def self._resource_repositories(*values)
        if values.empty?
          Array.new @@repos
        else
          index = (@@index ||= {})
          matches = values.map { |value|
            value = symbolize(value)
            @@index.values_at(:id).compact.inject([]) { |result, coll|
              if coll.has_key?(value)
                result.concat(coll[value])
              end
              result
            }.uniq.first
          }
          matches.size == 1 ? matches.first : matches
        end
      end
      private_class_method :_resource_repositories

      def self.symbolize(key)
        key.to_s.to_sym
      end
      private_class_method :symbolize

      def self.autovivified_hash(value = :self)
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
      private_class_method :autovivified_hash

      # TODO Document
      module Factory

        def id
          raise NotImplementedError.new("#{__method__} is not implemented.")
        end

        def create_repository(options = {})
          raise NotImplementedError.new("#{__method__} is not implemented.")
        end
      end

      # FormatError represents an error when the specified format is not
      # supported by the {Format} extension framework.
      #
      # TODO Do we need to reframe this for Resource Repository extensions.
      class FormatError < StandardError

        FORMAT_ERROR = %Q{Format "%s" is not supported.}

        def initialize(format)
          super(FORMAT_ERROR % format)
        end
      end
    end
  end
end
