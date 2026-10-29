# frozen_string_literal: true

require 'ripper'
require_relative '../ruby_compile_engine'

module SlimLint
  # Checks that the Ruby code a template compiles into is valid.
  class Linter::RubySyntax < Linter
    include LinterRegistry

    MESSAGE = 'Template compiles to invalid Ruby code: %s'

    on_start do |_sexp|
      ruby = SlimLint::RubyCompileEngine.new.call(document.source)
      # Wrapped in a method, as Rails does, so `yield` is valid. Line 0 is the
      # `def`, so lines in the template and in the generated code match.
      error = SyntaxErrorFinder.new("def template\n#{ruby}\nend", document.file, 0).first_error
      next unless error

      line, message = error
      dummy_node = Struct.new(:line)
      report_lint(dummy_node.new([line, document.source_lines.size].min), MESSAGE % message)
    end

    # Ripper parser collecting the syntax errors it encounters.
    class SyntaxErrorFinder < Ripper
      # Parses the code and returns its first syntax error, if any.
      #
      # @return [Array(Integer, String), nil] line and message of the error
      def first_error
        @errors = []
        parse
        @errors.first
      end

      private

      def on_parse_error(message)
        @errors << [lineno, message]
      end
    end
  end
end
