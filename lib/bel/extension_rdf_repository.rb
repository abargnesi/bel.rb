module BEL
  module Extension

    # TODO Document
    module RdfRepository

      MUTEX = Mutex.new
      private_constant :MUTEX

      # TODO Document
      def self.register_rdf_repository(repo)
        MUTEX.synchronize {
          @@repos ||= []
          # vivified hash, like: { :foo => { :bar => [] } }
          @@index ||= autovivified_hash(autovivified_hash([]))
          
          if _rdf_repositories(repo.id)
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
      def self.rdf_repositories(*values)
        MUTEX.synchronize {
          _rdf_repositories(*values)
        }
      end

      # TODO Document
      def self._rdf_repositories(*values)
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
      private_class_method :_rdf_repositories

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
    end
  end
end
