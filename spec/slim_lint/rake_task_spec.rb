# frozen_string_literal: true

require 'spec_helper'
require 'slim_lint/rake_task'
require 'tempfile'

describe SlimLint::RakeTask do
  before(:all) do
    SlimLint::RakeTask.new do |t|
      t.quiet = true
    end
  end

  let(:file) do
    Tempfile.new(%w[slim-file .slim]).tap do |f|
      f.write(slim)
      f.close
    end
  end

  def run_task
    Rake::Task[:slim_lint].tap do |t|
      t.reenable # Allows us to execute task multiple times
      t.invoke(file.path)
    end
  end

  context 'when Slim document is valid' do
    let(:slim) { "p Hello world\n" }

    it 'executes without error' do
      expect { run_task }.not_to raise_error
    end
  end

  context 'when Slim document is invalid' do
    let(:slim) { '%tag' }

    it 'raises an error' do
      expect { run_task }.to raise_error RuntimeError
    end
  end

  describe 'command line arguments' do
    let(:slim) { "p Hello world\n" }

    before { require 'slim_lint/cli' }

    it 'passes only the files by default' do
      SlimLint::CLI.any_instance.should_receive(:run).with([file.path]).and_return(0)
      run_task
    end

    context 'when options are specified' do
      before(:all) do
        # Rake only records task descriptions when listing tasks (`rake -T`)
        record_task_metadata = Rake::TaskManager.record_task_metadata
        Rake::TaskManager.record_task_metadata = true
        Rake.application.last_description = nil
        SlimLint::RakeTask.new(:slim_lint_with_options) do |t|
          t.config = 'custom.yml'
          t.options = %w[--reporter json]
          t.quiet = true
        end
      ensure
        Rake::TaskManager.record_task_metadata = record_task_metadata
      end

      it 'passes the options before the files' do
        SlimLint::CLI.any_instance.should_receive(:run)
                     .with(['--config', 'custom.yml', '--reporter', 'json', file.path])
                     .and_return(0)

        Rake::Task[:slim_lint_with_options].tap do |t|
          t.reenable
          t.invoke(file.path)
        end
      end

      it 'includes the options in the task description' do
        Rake::Task[:slim_lint_with_options].comment.should ==
          'Run `slim-lint --config custom.yml --reporter json . [files...]`'
      end
    end
  end
end
