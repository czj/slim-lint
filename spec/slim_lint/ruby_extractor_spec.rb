# frozen_string_literal: true

require 'spec_helper'

describe SlimLint::RubyExtractor do
  let(:extractor) { described_class.new }

  describe '#extract' do
    let(:sexp) { SlimLint::RubyExtractEngine.new.call(normalize_indent(slim)) }
    subject { extractor.extract(sexp) }

    context 'with an empty Slim document' do
      let(:slim) { '' }
      its(:source) { should == '' }
      its(:source_map) { should == {} }
    end

    context 'with verbatim text' do
      let(:slim) { <<-SLIM }
        | Hello world
      SLIM

      its(:source) { should == '_slim_lint_puts_0' }
      its(:source_map) { should == { 1 => 1 } }
    end

    context 'with verbatim text on multiple lines' do
      let(:slim) { <<-SLIM }
        |
          Hello
          world
      SLIM

      its(:source) { should == '_slim_lint_puts_0' }
      its(:source_map) { should == { 1 => 2 } }
    end

    context 'with verbatim text with trailing whitespace' do
      let(:slim) { <<-SLIM }
        ' Hello world
      SLIM

      its(:source) { should == '_slim_lint_puts_0' }
      its(:source_map) { should == { 1 => 1 } }
    end

    context 'with inline static HTML' do
      let(:slim) { <<-SLIM }
        <p><b>Hello world!</b></p>
      SLIM

      its(:source) { should == '_slim_lint_puts_0' }
      its(:source_map) { should == { 1 => 1 } }
    end

    context 'with control code' do
      let(:slim) { <<-SLIM }
        - some_expression
      SLIM

      its(:source) { should == 'some_expression' }
      its(:source_map) { should == { 1 => 1 } }
    end

    context 'with output code' do
      let(:slim) { <<-SLIM }
        = some_expression
      SLIM

      its(:source) { should == 'some_expression' }
      its(:source_map) { should == { 1 => 1 } }
    end

    context 'with output code with block contents' do
      let(:slim) { <<-SLIM }
        = simple_form_for User.new, url: some_url do |f|
          = f.input :email, autofocus: true
      SLIM

      its(:source) { should == normalize_indent(<<-RUBY).chomp }
        simple_form_for User.new, url: some_url do |f|
        f.input :email, autofocus: true
        end
      RUBY

      its(:source_map) { { 1 => 1, 2 => 2, 3 => 1 } }
    end

    context 'with output without escaping' do
      let(:slim) { <<-SLIM }
        == some_expression
      SLIM

      its(:source) { should == 'some_expression' }
      its(:source_map) { should == { 1 => 1 } }
    end

    context 'with a code comment' do
      let(:slim) { <<-SLIM }
        / This line will not appear
      SLIM

      its(:source) { should == '' }
      its(:source_map) { should == {} }
    end

    context 'with an HTML comment' do
      let(:slim) { <<-SLIM }
        /! This line will appear
      SLIM

      its(:source) { should == '_slim_lint_puts_0' }
      its(:source_map) { should == { 1 => 1 } }
    end

    context 'with an Internet Explorer conditional comment' do
      let(:slim) { <<-SLIM }
        /[if IE]
          Get a better browser
      SLIM

      its(:source) { should == "_slim_lint_puts_0\n_slim_lint_puts_1" }
      its(:source_map) { should == { 1 => 2, 2 => 2 } }
    end

    context 'with doctype tag' do
      let(:slim) { <<-SLIM }
        doctype xml
      SLIM

      its(:source) { should == '_slim_lint_puts_0' }
      its(:source_map) { should == { 1 => 1 } }
    end

    context 'with an HTML tag' do
      let(:slim) { <<-SLIM }
        p A paragraph
      SLIM

      its(:source) { should == "_slim_lint_puts_0\n_slim_lint_puts_1" }
      its(:source_map) { should == { 1 => 1, 2 => 1 } }
    end

    context 'with an HTML tag with interpolation' do
      let(:slim) { <<-SLIM }
        p A \#{adjective} paragraph for \#{noun}
      SLIM

      its(:source) { should == normalize_indent(<<-RUBY).chomp }
      _slim_lint_puts_0
      _slim_lint_puts_1
      adjective
      _slim_lint_puts_2
      noun
      RUBY

      its(:source_map) { should == { 1 => 1, 2 => 1, 3 => 1, 4 => 1, 5 => 1 } }
    end

    context 'with an HTML tag with static attributes' do
      let(:slim) { <<-SLIM }
        p class="highlight"
      SLIM

      its(:source) { should == "_slim_lint_puts_0\n_slim_lint_puts_1" }
      its(:source_map) { should == { 1 => 1, 2 => 1 } }
    end

    context 'with an HTML tag with Ruby attributes' do
      let(:slim) { <<-SLIM }
        p class=user.class id=user.id
      SLIM

      its(:source) { should == normalize_indent(<<-RUBY).chomp }
        _slim_lint_puts_0
        user.class
        user.id
      RUBY

      its(:source_map) { should == { 1 => 1, 2 => 1, 3 => 1 } }
    end

    context 'with a dynamic tag splat' do
      let(:slim) { <<-SLIM }
        *some_dynamic_tag Hello World!
      SLIM

      its(:source) { should == normalize_indent(<<-RUBY).chomp }
        _slim_lint_puts_0
        some_dynamic_tag
        _slim_lint_puts_1
      RUBY

      its(:source_map) { should == { 1 => 1, 2 => 1, 3 => 1 } }
    end

    context 'with an if statement' do
      let(:slim) { <<-SLIM }
        - if condition_true?
          | It's true!
      SLIM

      its(:source) { should == normalize_indent(<<-RUBY).chomp }
        if condition_true?
        _slim_lint_puts_0
        end
      RUBY

      its(:source_map) { should == { 1 => 1, 2 => 2, 3 => 3 } }
    end

    context 'with an if/else statement' do
      let(:slim) { <<-SLIM }
        - if condition_true?
          | It's true!
        - else
          | It's false!
      SLIM

      its(:source) { should == normalize_indent(<<-RUBY).chomp }
        if condition_true?
        _slim_lint_puts_0
        else
        _slim_lint_puts_1
        end
      RUBY

      its(:source_map) { should == { 1 => 1, 2 => 2, 3 => 3, 4 => 4, 5 => 5 } }
    end

    context 'with an if/elsif/else statement' do
      let(:slim) { <<-SLIM }
        - if condition_true?
          | It's true!
        - elsif something_else?
          | ???
        - else
          | It's false!
      SLIM

      its(:source) { should == normalize_indent(<<-RUBY).chomp }
        if condition_true?
        _slim_lint_puts_0
        elsif something_else?
        _slim_lint_puts_1
        else
        _slim_lint_puts_2
        end
      RUBY

      its(:source_map) { should == { 1 => 1, 2 => 2, 3 => 3, 4 => 4, 5 => 5, 6 => 6, 7 => 7 } }
    end

    context 'with an if/else statement with statements following it' do
      let(:slim) { <<-SLIM }
        - if condition_true?
          | It's true!
        - else
          | It's false!
        - following_statement
        - another_statement
      SLIM

      its(:source) { should == normalize_indent(<<-RUBY).chomp }
        if condition_true?
        _slim_lint_puts_0
        else
        _slim_lint_puts_1
        end
        following_statement
        another_statement
      RUBY

      its(:source_map) { should == { 1 => 1, 2 => 2, 3 => 3, 4 => 4, 5 => 5, 6 => 5, 7 => 6 } }
    end

    context 'with an output statement with statements following it' do
      let(:slim) { <<-SLIM }
        = some_output
        - some_statement
        - another_statement
      SLIM

      its(:source) { should == normalize_indent(<<-RUBY).chomp }
        some_output
        some_statement
        another_statement
      RUBY

      its(:source_map) { should == { 1 => 1, 2 => 2, 3 => 3 } }
    end

    context 'with an output statement that spans multiple lines' do
      let(:slim) { <<-SLIM }
        = some_output 1,
                      2,
                      3
      SLIM

      its(:source) { should == normalize_indent(<<-RUBY).chomp }
      some_output 1,
      2,
      3
      RUBY

      its(:source_map) { should == { 1 => 1, 2 => 2, 3 => 3 } }
    end

    context 'with a control statement that spans multiple lines' do
      let(:slim) { <<-SLIM }
        - some_method 1,
                      2,
                      3
      SLIM

      its(:source) { should == normalize_indent(<<-RUBY).chomp }
      some_method 1,
      2,
      3
      RUBY

      its(:source_map) { should == { 1 => 1, 2 => 2, 3 => 3 } }
    end

    context 'with code ending with an omitted hash value' do
      let(:slim) { <<-SLIM }
        = render 'fields', f:
        - content_for :something do
          | Hello
      SLIM

      its(:source) { should == normalize_indent(<<-RUBY).chomp }
        (render 'fields', f:)
        content_for :something do
        _slim_lint_puts_0
        end
      RUBY

      its(:source_map) { should == { 1 => 1, 2 => 2, 3 => 3, 4 => 4 } }
    end

    context 'with code ending with an omitted hash value that spans multiple lines' do
      let(:slim) { <<-SLIM }
        = render 'fields',
                 f:
        - some_statement
      SLIM

      its(:source) { should == normalize_indent(<<-RUBY).chomp }
        (render 'fields',
        f:)
        some_statement
      RUBY

      its(:source_map) { should == { 1 => 1, 2 => 2, 3 => 3 } }
    end

    context 'with code ending with an omitted hash value before the end of a block' do
      let(:slim) { <<-SLIM }
        - items.each do |item|
          = render 'item', item:
        - case item
        - in name:
          = name
      SLIM

      its(:source) { should == normalize_indent(<<-RUBY).chomp }
        items.each do |item|
        render 'item', item:
        end
        case item
        in name:
        name
        end
      RUBY
    end

    context 'with code ending with an omitted hash value after a hash sign or a non-ASCII name' do
      let(:slim) { <<-SLIM }
        = link_to 'Top', '#', id:
        = render 'menu', café:
        - some_statement
      SLIM

      its(:source) { should == normalize_indent(<<-RUBY).chomp }
        (link_to 'Top', '#', id:)
        (render 'menu', café:)
        some_statement
      RUBY

      its(:source_map) { should == { 1 => 1, 2 => 2, 3 => 3 } }
    end

    context 'with code ending with a colon that is not an omitted hash value' do
      let(:slim) { <<-SLIM }
        = render 'fields', f: form
        = link_to 'Next:', path, class: Foo::Bar
        - foo = bar ? baz:
        = render 'fields' # see:
        = render 'fields', f: # with a comment
        - qux
      SLIM

      its(:source) { should == normalize_indent(<<-RUBY).chomp }
        render 'fields', f: form
        link_to 'Next:', path, class: Foo::Bar
        foo = bar ? baz:
        render 'fields' # see:
        render 'fields', f: # with a comment
        qux
      RUBY

      its(:source_map) { should == { 1 => 1, 2 => 2, 3 => 3, 4 => 4, 5 => 5, 6 => 6 } }
    end

    context 'with a control statement ending with an omitted hash value' do
      let(:slim) { <<-SLIM }
        - if allowed? user:
          | Allowed
      SLIM

      its(:source) { should == normalize_indent(<<-RUBY).chomp }
        if allowed? user:
        _slim_lint_puts_0
        end
      RUBY

      its(:source_map) { should == { 1 => 1, 2 => 2, 3 => 3 } }
    end
  end
end
