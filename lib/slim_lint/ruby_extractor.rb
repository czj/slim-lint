# frozen_string_literal: true

require 'ripper'

module SlimLint
  # Utility class for extracting Ruby script from a Slim template that can then
  # be linted with a Ruby linter (i.e. is "legal" Ruby).
  #
  # The goal is to turn this:
  #
  #    - if items.any?
  #      table#items
  #      - for item in items
  #        tr
  #          td.name = item.name
  #          td.price = item.price
  #    - else
  #       p No items found.
  #
  # into (something like) this:
  #
  #    if items.any?
  #      for item in items
  #        puts item.name
  #        puts item.price
  #    else
  #      puts 'No items found'
  #    end
  #
  # The translation won't be perfect, and won't make any real sense, but the
  # relationship between variable declarations/uses and the flow control graph
  # will remain intact.
  class RubyExtractor
    include SexpVisitor
    extend SexpVisitor::DSL

    # Stores the extracted source and a map of lines of generated source to the
    # original source that created them.
    #
    # @attr_reader source [String] generated source code
    # @attr_reader source_map [Hash] map of line numbers from generated source
    #   to original source line number
    RubySource = Struct.new(:source, :source_map)

    # Matches code opening a control structure or clause, which parentheses
    # would break.
    STARTS_WITH_CONTROL_KEYWORD =
      /\A\s*(?:if|unless|else|elsif|when|in|begin|rescue|ensure|case|while|until)\b/

    # Matches code that Ruby can't read as a hash value.
    STARTS_WITH_CLAUSE_KEYWORD = /\A\s*(?:end|else|elsif|when|in|rescue|ensure)\b/

    # Ripper tokens to skip when looking for the last token of the code.
    BLANK_TOKENS = %i[on_sp on_nl on_ignored_nl].freeze

    # Extracts Ruby code from Sexp representing a Slim document.
    #
    # @param sexp [SlimLint::Sexp]
    # @return [SlimLint::RubyExtractor::RubySource]
    def extract(sexp)
      trigger_pattern_callbacks(sexp)
      RubySource.new(@source_lines.join("\n"), @source_map)
    end

    on_start do |_sexp|
      @source_lines = []
      @source_map = {}
      @line_count = 0
      @dummy_puts_count = 0
      @omitted_hash_value_line = nil
    end

    on [:html, :doctype] do |sexp|
      append_dummy_puts(sexp)
    end

    on [:html, :tag] do |sexp|
      append_dummy_puts(sexp)
    end

    on [:static] do |sexp|
      append_dummy_puts(sexp)
    end

    on [:dynamic] do |sexp|
      _, ruby = sexp
      append(ruby, sexp)
    end

    on [:code] do |sexp|
      _, ruby = sexp
      append(ruby, sexp)
    end

    private

    # Append code to the buffer.
    #
    # @param code [String]
    # @param sexp [SlimLint::Sexp]
    def append(code, sexp)
      return if code.empty?

      original_line = sexp.line
      code = code.to_s
      wrap_omitted_hash_value unless code.match?(STARTS_WITH_CLAUSE_KEYWORD)
      @omitted_hash_value_line = (@line_count if omitted_hash_value?(code))

      # For code that spans multiple lines, the resulting code will span
      # multiple lines, so we need to create a mapping for each line.
      code.split("\n").each_with_index do |line, index|
        @source_lines << line
        @line_count += 1
        @source_map[@line_count] = original_line + index
      end
    end

    # Slim compiles each line on its own, but the extracted lines are joined, so
    # Ruby would read the next code as the value of a trailing omitted hash
    # value. Wrapping the previous code in parentheses keeps it to its own
    # lines. Before `end` and the like there is nothing to wrap, and RuboCop
    # would flag parentheses around the only statement of a block.
    def wrap_omitted_hash_value
      return unless @omitted_hash_value_line

      @source_lines[@omitted_hash_value_line] = "(#{@source_lines[@omitted_hash_value_line]}"
      @source_lines[-1] = "#{@source_lines[-1]})"
    end

    # Whether the code ends with a hash value omitted (`render 'form', f:`),
    # outside a control statement, which parentheses would break. A trailing
    # comment ends it too, and would swallow the closing parenthesis.
    #
    # @param code [String]
    # @return [Boolean]
    def omitted_hash_value?(code)
      return false unless code.rstrip.end_with?(':') && !code.match?(STARTS_WITH_CONTROL_KEYWORD)

      _, last_token = Ripper.lex(code).reverse_each.find { |_, type| !BLANK_TOKENS.include?(type) }
      last_token == :on_label
    end

    def append_dummy_puts(sexp)
      append("_slim_lint_puts_#{@dummy_puts_count}", sexp)
      @dummy_puts_count += 1
    end
  end
end
