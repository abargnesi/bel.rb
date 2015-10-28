module BEL::Extension

  module Query

    include Enumerable

    def each(types = :all)
      types = (types == :all) ? self.extension_types : [types].flatten

      extension_paths = types.reduce([]) { |paths, type|
        path_glob = extension_path_glob(type)
        unless path_glob
          raise "Extension type #{extension_type} not supported."
        end

        paths << Gem.find_files_from_load_path(path_glob)
        paths
      }.flatten!

      extension_paths.each do |ext_path|
        Kernel.require ext_path
      end

      if block_given?
        @extensions.each do |ext|
          yield ext
        end
      else
        Enumerator.new do |yielder|
          @extensions.each do |ext|
            yielder << ext
          end
        end
      end
    end
  end
end
