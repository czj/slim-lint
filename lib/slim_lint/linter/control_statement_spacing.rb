# frozen_string_literal: true

module SlimLint
  # Checks for missing or superfluous spacing before and after control statements.
  class Linter::ControlStatementSpacing < Linter
    include LinterRegistry
    support_autocorrect

    MESSAGE_OUTPUT = 'Please add a space before and after the `=`'
    MESSAGE_OUTPUT_WITHOUT_SPACE_BEFORE = 'Please add a space after the `=` but none before'
    MESSAGE_STANDALONE_OUTPUT = 'Please add a space after the `=`'
    MESSAGE_CONTROL = 'Please add a space after the `-`'

    # Matches the indentation, the operator and the spacing after it of an
    # output statement that is not attached to a tag (e.g. `== foo`).
    STANDALONE_OUTPUT_SPACING = /^(\s*)(==?[<>]*)(\s*)/

    SourceLocation = Struct.new(:line)
    private_constant :SourceLocation

    on [:html, :tag, anything, [],
         [:slim, :output, anything, capture(:ruby, anything)]] do |sexp|
      # Fetch original Slim code that contains an element with a control statement.
      ruby = captures[:ruby]
      location, line = source_line_for(sexp, /=[=<>]* *#{Regexp.escape(ruby[/[^\n]*/])}/)
      next unless line

      # Remove any Ruby code, because our regexp below must not match inside Ruby.
      line = line.sub(ruby, 'x')

      spacing = output_spacing(ruby)
      if config['space_before_output']
        next if line =~ /[^ ] ==?<?>? [^ ]/

        report_lint(location, MESSAGE_OUTPUT,
                    correction: ->(source_line) { source_line.sub(spacing, ' \1 ') })
      else
        next if line =~ /[^ ]==?<?>? [^ ]/

        report_lint(location, MESSAGE_OUTPUT_WITHOUT_SPACE_BEFORE,
                    correction: ->(source_line) { source_line.sub(spacing, '\1 ') })
      end
    end

    # Output statements attached to a tag are the tag's content, whereas
    # standalone ones (`= foo` on its own line) are children of a `:multi`.
    on [:multi] do |sexp|
      sexp.each do |child|
        next unless child.is_a?(Sexp) && child.match?([:slim, :output])

        check_standalone_output(child)
      end
    end

    on [:slim, :control] do |sexp|
      ruby = sexp[2]
      location, line = source_line_for(sexp, /- *#{Regexp.escape(ruby[/[^\n]*/])}/)
      next unless line

      next if line =~ /^ *- [^ ]/

      report_lint(location, MESSAGE_CONTROL,
                  correction: ->(source_line) { source_line.sub(/^(\s*)-\s*/, '\1- ') })
    end

    private

    # Matches the operator of an output statement attached to a tag (`=` or
    # `==`, optionally followed by `<`, `>` or `'`) and the whitespace around
    # it. The match is anchored on the Ruby code ending the line, so that an
    # `=` inside the tag attributes (`a[href="x"]= foo`) is never touched.
    #
    # @param ruby [String] Ruby code of the output statement
    # @return [Regexp]
    def output_spacing(ruby)
      /\s*(==?['<>]*)\s*(?=#{Regexp.escape(ruby[/[^\n]*/])}\s*\z)/
    end

    # @param sexp [SlimLint::Sexp] a `[:slim, :output, ...]` not attached to a tag
    def check_standalone_output(sexp)
      ruby = sexp[3]
      pattern = /^\s*==?[<>]*\s*#{Regexp.escape(ruby[/[^\n]*/])}/
      location, line = source_line_for(sexp, pattern, fallback: false)
      return if line.nil? || line =~ /^\s*==?[<>]* [^ ]/

      correction = ->(source_line) { source_line.sub(STANDALONE_OUTPUT_SPACING, '\1\2 ') }
      report_lint(location, MESSAGE_STANDALONE_OUTPUT, correction: correction)
    end

    # Finds the original Slim source line for the given Sexp.
    #
    # Backslash (`\`) and comma (`,`) line continuations in preceding
    # attributes are collapsed by the Slim parser without emitting a newline,
    # which causes the line number reported for subsequent Sexps to be too low
    # (see https://github.com/sds/slim-lint/issues/201). We compensate by
    # searching forward from the reported line for the line that actually
    # contains the statement, falling back to the reported line otherwise
    # (unless `fallback` is false). The location is returned alongside the
    # line so that lints, and their corrections, target the actual line.
    #
    # @param sexp [SlimLint::Sexp]
    # @param pattern [Regexp] matches the source line containing the statement
    # @param fallback [Boolean] whether to fall back to the reported line
    # @return [Array(SourceLocation, String), nil]
    def source_line_for(sexp, pattern, fallback: true)
      index = sexp.line - 1
      offset = (document.source_lines[index..] || []).index { |line| line =~ pattern }
      offset ||= 0 if fallback
      return unless offset

      [SourceLocation.new(sexp.line + offset), document.source_lines[index + offset]]
    end
  end
end
