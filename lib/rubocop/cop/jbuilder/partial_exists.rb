# frozen_string_literal: true

TEST_FILENAME = File.join(Dir.pwd, "app/views/testing/show.json.jbuilder")

module RuboCop
  module Cop
    module Jbuilder
      class PartialExists < Base
        MSG = "Partial not found. Looked for: %<path>s"

        RESTRICT_ON_SEND = %i[partial! array!].freeze

        def_node_matcher :has_partial?, <<~PATTERN
          {
            (send (send nil? :json) :partial! $str ...)
            (send (send nil? :json) :array! ... (hash (pair (sym :partial) $str) ...))
          }
        PATTERN

        def on_send(node)
          has_partial?(node) do |actual|
            full_path = get_view_path_from(actual)
            path = full_path.sub(rails_root_dirname(node) + "/", "")
            add_offense(actual, message: format(MSG, path:)) unless File.exist?(full_path)
          end
        end

        private

        def get_view_path_from(node)
          partial = node.source[1..-2]
          segments = partial.split("/")
          segments.last.sub!(/.*/, '_\&.json.jbuilder')

          dirname = (segments.count == 1) ? sut_dirname(node) : rails_views_dirname(node)
          File.join(dirname, *segments)
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
