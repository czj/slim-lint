# frozen_string_literal: true

require 'spec_helper'

describe SlimLint::Reporter::DefaultReporter do
  describe '#display_report' do
    let(:io) { StringIO.new }
    let(:output) { io.string }
    let(:logger) { SlimLint::Logger.new(io) }
    let(:files) { ['some-filename.slim', 'other-filename.slim'] }
    let(:report) { SlimLint::Report.new(lints, files) }
    let(:reporter) { described_class.new(logger) }

    subject { reporter.display_report(report) }

    context 'when there are no lints' do
      let(:lints) { [] }

      it 'prints only the summary' do
        subject
        output.should == "2 files inspected, no lints detected\n"
      end

      context 'when a single file was inspected' do
        let(:files) { ['some-filename.slim'] }

        it 'uses the singular in the summary' do
          subject
          output.should == "1 file inspected, no lints detected\n"
        end
      end
    end

    context 'when there are lints' do
      let(:filenames)    { ['some-filename.slim', 'other-filename.slim'] }
      let(:lines)        { [502, 724] }
      let(:descriptions) { ['Description of lint 1', 'Description of lint 2'] }
      let(:severities)   { [:warning] * 2 }
      let(:linter)       { double(name: 'SomeLinter') }

      let(:lints) do
        filenames.each_with_index.map do |filename, index|
          SlimLint::Lint.new(linter, filename, lines[index], descriptions[index], severities[index])
        end
      end

      it 'prints each lint on its own line, then a blank line and the summary' do
        subject
        output.lines.count.should == 4
        output.lines[2].should == "\n"
      end

      it 'ends with a summary of the files inspected and lints detected' do
        subject
        output.lines.last.should == "2 files inspected, 2 lints detected\n"
      end

      context 'when there is a single lint' do
        let(:filenames) { ['some-filename.slim'] }

        it 'uses the singular in the summary' do
          subject
          output.lines.last.should == "2 files inspected, 1 lint detected\n"
        end
      end

      it 'prints a trailing newline' do
        subject
        output[-1].should == "\n"
      end

      it 'prints the filename for each lint' do
        subject
        filenames.each do |filename|
          output.scan(/#{filename}:/).count.should == 1
        end
      end

      it 'prints the line number for each lint' do
        subject
        lines.each do |line|
          output.scan(/#{line}/).count.should == 1
        end
      end

      it 'prints the description for each lint' do
        subject
        descriptions.each do |description|
          output.scan(/#{description}/).count.should == 1
        end
      end

      context 'when lints are warnings' do
        it 'prints the warning severity code on each lint line' do
          subject
          output.lines.first(2).each do |line|
            line.scan(/\[W\]/).count.should == 1
          end
        end
      end

      context 'when lints are errors' do
        let(:severities) { [:error] * 2 }

        it 'prints the error severity code on each lint line' do
          subject
          output.lines.first(2).each do |line|
            line.scan(/\[E\]/).count.should == 1
          end
        end
      end

      context 'when a lint has been corrected' do
        before { lints.first.corrected = true }

        it 'marks the corrected lint as `[Corrected]`' do
          subject
          output.should include '[Corrected]'
        end

        it 'does not mark the uncorrected lint as `[Corrected]`' do
          subject
          output.scan(/\[Corrected\]/).count.should == 1
        end

        it 'reports the corrected count in the summary' do
          subject
          output.lines.last.should == "2 files inspected, 2 lints detected, 1 lint corrected\n"
        end
      end

      context 'when lint has no associated linter' do
        let(:linter) { nil }

        it 'prints the description for each lint' do
          subject
          descriptions.each do |description|
            output.scan(/#{description}/).count.should == 1
          end
        end
      end
    end
  end
end
