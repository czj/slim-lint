# frozen_string_literal: true

module SlimLint::Filters
  # A version of {Slim::Embedded} which doesn't render the engines Slim runs
  # through Tilt at compile time (Markdown, Sass, CoffeeScript, etc.), since
  # those need gems the linted project may not have installed.
  class EmbeddedWithoutTilt < Slim::Embedded
    # Engines whose content can contain Ruby code at runtime.
    RUBY_ENGINES = %i[css javascript ruby].freeze

    # Engines are registered on {Slim::Embedded} itself, not on subclasses.
    #
    # @return [Hash]
    def self.engines
      Slim::Embedded.engines
    end

    # Handle embedded engine expressions `[:slim, :embedded, name, body, attrs]`
    #
    # @param name [String]
    # @param body [Array]
    # @param attrs [Array]
    # @return [Array]
    def on_slim_embedded(name, body, attrs)
      return super if RUBY_ENGINES.include?(name.to_sym)

      Slim::NewlineCollector.new.call(body)
    end
  end
end
