# frozen_string_literal: true

module SlimLint
  # Outputs lints in a simple format with the filename, line number, and lint
  # message, followed by a summary of the files inspected.
  class Reporter::DefaultReporter < Reporter
    def display_report(report)
      sorted_lints = report.lints.sort_by { |l| [l.filename, l.line] }

      sorted_lints.each do |lint|
        print_location(lint)
        print_type(lint)
        print_message(lint)
      end

      log.newline unless sorted_lints.empty?
      print_summary(report)
    end

    private

    def print_location(lint)
      log.info lint.filename, false
      log.log ':', false
      log.bold lint.line, false
    end

    def print_type(lint)
      if lint.error?
        log.error ' [E] ', false
      else
        log.warning ' [W] ', false
      end
    end

    def print_message(lint)
      if lint.linter
        log.success("#{lint.linter.name}: ", false)
      end

      log.log lint.message, false
      lint.corrected? ? log.success(' [Corrected]') : log.newline
    end

    def print_summary(report)
      corrected_count = report.lints.count(&:corrected?)

      summary = "#{pluralize(report.files.count, 'file')} inspected, "
      summary += report.lints.empty? ? 'no lints' : pluralize(report.lints.count, 'lint')
      summary += ' detected'
      summary += ", #{pluralize(corrected_count, 'lint')} corrected" if corrected_count.positive?

      log.log summary
    end

    def pluralize(count, noun)
      "#{count} #{noun}#{'s' unless count == 1}"
    end
  end
end
