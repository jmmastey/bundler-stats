module Bundler
  module Stats
    class FilePathResolver
      FILES_MAP = {
        "gems.rb" => "gems.locked",
        "Gemfile" => "Gemfile.lock"
      }

      def initialize(specific_gemfile_path = nil)
        @specific_gemfile_path = specific_gemfile_path
      end

      def gemfile_path
        resolve_file_path(FILES_MAP.keys, specific_gemfile_path)
      end

      def lockfile_path
        resolve_file_path(FILES_MAP.values, resolve_lockfile_path)
      end

      private

      attr_reader :specific_gemfile_path

      def resolve_lockfile_path
        return unless specific_gemfile_path

        file_path = Pathname.new(specific_gemfile_path)
        file_name = file_path.basename.to_s
        locked_file_name = FILES_MAP[file_name]
        raise ArgumentError, "Invalid file name: #{file_name}" if locked_file_name.nil?
        file_path.dirname.join(locked_file_name).to_s
      end

      def resolve_file_path(file_names, custom_path)
        if custom_path
          raise ArgumentError, "Couldn't find #{custom_path} file path" unless File.exist?(custom_path)
          return custom_path
        end

        find_file_path(file_names)
      end

      def find_file_path(file_names)
        cwd = Pathname.new(".")
        until cwd.realdirpath.root? do
          file_names.each do |file|
            return (cwd + file).to_s if File.exist?(cwd + file)
          end
          cwd = cwd.parent
        end
        raise ArgumentError, "Couldn't find #{file_names.join(" nor ")} in this directory or parents"
      end
    end
  end
end
