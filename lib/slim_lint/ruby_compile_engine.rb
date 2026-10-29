# frozen_string_literal: true

module SlimLint
  # Compiles a Slim template into the Ruby code {Slim::Engine} would run, so
  # it can be checked by the {Linter::RubySyntax} linter.
  class RubyCompileEngine < Slim::Engine
    replace Slim::Embedded, SlimLint::Filters::EmbeddedWithoutTilt
  end
end
