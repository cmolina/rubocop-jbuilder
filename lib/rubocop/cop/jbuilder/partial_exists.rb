# frozen_string_literal: true

require 'pathname'

TEST_FILENAME = File.join(Dir.pwd, "app/views/testing/nested/show.json.jbuilder")

module RuboCop
  module Cop
    module Jbuilder
      class PartialExists < Base
        MSG = "Partial not found. Looked for: %<paths>s"

        def_node_matcher :has_partial?, <<~PATTERN
          {
            (send (send nil? :json) :partial! $str ...)
            (send (send nil? :json) ... (hash (pair (sym :partial) $str) ...))
          }
        PATTERN

        def on_send(node)
          has_partial?(node) do |actual|
            all_paths = get_view_paths_from(actual)

            return if all_paths.any? { |full_path| File.exist?(full_path) }

            base_path = rails_root_dirname(node)
            relative_paths = all_paths.map { |full_path| relative_path(full_path, base_path) }
            add_offense(actual, message: format(MSG, paths: relative_paths.join(", ")))
          end
        end

        private

        def get_view_paths_from(node)
          partial = node.source[1..-2]
          segments = partial.split("/")
          segments.last.sub!(/.*/, '_\&.json.jbuilder')

          specific_path = segments.count != 1
          return [File.join(rails_views_dirname(node), *segments)] if specific_path

          paths = []
          current_dirname = sut_dirname(node)
          while current_dirname != rails_views_dirname(node)
            paths << File.join(current_dirname, *segments)
            current_dirname = File.expand_path("..", current_dirname)
          end
          paths
        end

        def relative_path(full_path, base_path)
          full = Pathname.new(full_path)
          base = Pathname.new(base_path)
          full.relative_path_from(base).to_s
        end

        def sut_dirname(node)
          File.dirname(filename(node))
        end

        def rails_views_dirname(node)
          File.join(rails_root_dirname(node), "app/views")
        end

        def rails_root_dirname(node)
          filename(node).split("/app/").first
        end

        def filename(node)
          filename = node.location.expression.source_buffer.name

          (filename == "(string)") ? TEST_FILENAME : filename
        end
      end
    end
  end
end
