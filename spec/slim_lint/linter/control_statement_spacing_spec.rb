# frozen_string_literal: true

require 'spec_helper'

describe SlimLint::Linter::ControlStatementSpacing do
  include_context 'linter'

  context 'element missing space before =' do
    let(:slim) { 'div= bad' }

    it { should report_lint }
  end

  context 'element missing space after =' do
    let(:slim) { 'div =bad' }

    it { should report_lint }
  end

  context 'element missing space around =' do
    let(:slim) { 'div=bad' }

    it { should report_lint }
  end

  context 'element too much space before =' do
    let(:slim) { 'div  =bad' }

    it { should report_lint }
  end

  context 'element too much space after =' do
    let(:slim) { 'div=  bad' }

    it { should report_lint }
  end

  context 'id missing space before =' do
    let(:slim) { '#submit= bad' }

    it { should report_lint }
  end

  context 'id missing space after =' do
    let(:slim) { '#submit =bad' }

    it { should report_lint }
  end

  context 'id missing space around =' do
    let(:slim) { '#submit=bad' }

    it { should report_lint }
  end

  context 'id and class missing space around =' do
    let(:slim) { '.some-class#submit=bad' }

    it { should report_lint }
  end

  context 'id too much space before =' do
    let(:slim) { '#submit  =bad' }

    it { should report_lint }
  end

  context 'id too much space after =' do
    let(:slim) { '#submit=  bad' }

    it { should report_lint }
  end

  context 'class missing space before =' do
    let(:slim) { '.klass= bad' }

    it { should report_lint }
  end

  context 'class missing space after =' do
    let(:slim) { '.klass =bad' }

    it { should report_lint }
  end

  context 'class missing space around =' do
    let(:slim) { '.klass=bad' }

    it { should report_lint }
  end

  context 'class too much space before =' do
    let(:slim) { '.klass  =bad' }

    it { should report_lint }
  end

  context 'class too much space after =' do
    let(:slim) { '.klass=  bad' }

    it { should report_lint }
  end

  context 'class with hyphen missing space before =' do
    let(:slim) { '.some-klass= bad' }

    it { should report_lint }
  end

  context 'class with hyphen missing space after =' do
    let(:slim) { '.some-klass =bad' }

    it { should report_lint }
  end

  context 'class with hyphen missing space around =' do
    let(:slim) { '.some-klass=bad' }

    it { should report_lint }
  end

  context 'class with hyphen too much space before =' do
    let(:slim) { '.some-klass  =bad' }

    it { should report_lint }
  end

  context 'class with hyphen too much space after =' do
    let(:slim) { '.some-klass=  bad' }

    it { should report_lint }
  end

  context 'ruby code that contains a properly formatted equal sign' do
    let(:slim) { 'div =bad = 1' }

    it { should report_lint }
  end

  context 'ruby code that contains a properly formatted equal sign' do
    let(:slim) { 'div= bad = 1' }

    it { should report_lint }
  end

  context 'ruby code that contains a properly formatted equal sign' do
    let(:slim) { 'div  = bad = 1' }

    it { should report_lint }
  end

  # OK

  context 'ruby code that contains an equal sign without spacing' do
    let(:slim) { 'div = ok=1' }

    it { should_not report_lint }
  end

  context 'element with hyphen' do
    let(:slim) { 'div - ok' }

    it { should_not report_lint }
  end

  context 'control statement without element' do
    let(:slim) { '= ok' }

    it { should_not report_lint }
  end

  context 'attribute with equal sign without spacing' do
    let(:slim) { 'a href=ok' }

    it { should_not report_lint }
  end

  context 'when leading whitespace (=<) is used' do
    context 'and it has appropriate spacing' do
      let(:slim) { 'title =< "Something"' }

      it { should_not report_lint }
    end

    context 'and it lacks spacing on the left' do
      let(:slim) { 'title=< "Something"' }

      it { should report_lint }
    end

    context 'and it lacks spacing on the right' do
      let(:slim) { 'title =<"Something"' }

      it { should report_lint }
    end
  end

  context 'when trailing whitespace (=>) is used' do
    context 'and it has appropriate spacing' do
      let(:slim) { 'title => "Something"' }

      it { should_not report_lint }
    end

    context 'and it lacks spacing on the left' do
      let(:slim) { 'title=> "Something"' }

      it { should report_lint }
    end

    context 'and it lacks spacing on the right' do
      let(:slim) { 'title =>"Something"' }

      it { should report_lint }
    end
  end

  context 'when whitespace (=<>) is used' do
    context 'and it has appropriate spacing' do
      let(:slim) { 'title =<> "Something"' }

      it { should_not report_lint }
    end

    context 'and it lacks spacing on the left' do
      let(:slim) { 'title=<> "Something"' }

      it { should report_lint }
    end

    context 'and it lacks spacing on the right' do
      let(:slim) { 'title =<>"Something"' }

      it { should report_lint }
    end
  end

  context 'when HTML escape disabling (==) is used' do
    context 'and it has appropriate spacing' do
      let(:slim) { 'title == "Something"' }

      it { should_not report_lint }
    end

    context 'and it lacks spacing on the left' do
      let(:slim) { 'title== "Something"' }

      it { should report_lint }
    end

    context 'and it lacks spacing on the right' do
      let(:slim) { 'title =="Something"' }

      it { should report_lint }
    end
  end

  context 'when HTML escape disabling with leading whitespace (==<) is used' do
    context 'and it has appropriate spacing' do
      let(:slim) { 'title ==< "Something"' }

      it { should_not report_lint }
    end

    context 'and it lacks spacing on the left' do
      let(:slim) { 'title==< "Something"' }

      it { should report_lint }
    end

    context 'and it lacks spacing on the right' do
      let(:slim) { 'title ==<"Something"' }

      it { should report_lint }
    end
  end

  context 'when HTML escape disabling with trailing whitespace (==>) is used' do
    context 'and it has appropriate spacing' do
      let(:slim) { 'title ==> "Something"' }

      it { should_not report_lint }
    end

    context 'and it lacks spacing on the left' do
      let(:slim) { 'title==> "Something"' }

      it { should report_lint }
    end

    context 'and it lacks spacing on the right' do
      let(:slim) { 'title ==>"Something"' }

      it { should report_lint }
    end
  end

  context 'when HTML escape disabling with whitespace (==<>) is used' do
    context 'and it has appropriate spacing' do
      let(:slim) { 'title ==<> "Something"' }

      it { should_not report_lint }
    end

    context 'and it lacks spacing on the left' do
      let(:slim) { 'title==<> "Something"' }

      it { should report_lint }
    end

    context 'and it lacks spacing on the right' do
      let(:slim) { 'title ==<>"Something"' }

      it { should report_lint }
    end
  end

  context 'when control code is used' do
    context 'when one space is after -' do
      let(:slim) { '- ok' }

      it { should_not report_lint }
    end

    context 'when space is missing after -' do
      let(:slim) { '-bad' }

      it { should report_lint }
    end

    context 'when multiple spaces are after -' do
      let(:slim) { '-  bad' }

      it { should report_lint }
    end

    context 'when multiple spaces are after - but the code has "- "' do
      let(:slim) { '-  something?("foo - bar")' }

      it { should report_lint }
    end
  end

  # Backslash line continuations in a preceding attribute are collapsed by the
  # Slim parser, which shifts the reported line number of subsequent
  # statements. See https://github.com/sds/slim-lint/issues/201.
  context 'when a preceding attribute spans multiple lines' do
    context 'and the control statement has appropriate spacing' do
      let(:slim) { <<~'SLIM' }
        div class="a \
         b"
          - if 1 == 2
            | Hello
      SLIM

      it { should_not report_lint }
    end

    context 'and the control statement is missing spacing' do
      let(:slim) { <<~'SLIM' }
        div class="a \
         b"
          -if 1 == 2
            | Hello
      SLIM

      it { should report_lint count: 1, line: 3 }
    end

    context 'and the output statement has appropriate spacing' do
      let(:slim) { <<~'SLIM' }
        div class="a \
         b"
          span = foo
      SLIM

      it { should_not report_lint }
    end

    context 'and the output statement is missing spacing' do
      let(:slim) { <<~'SLIM' }
        div class="a \
         b"
          span= foo
      SLIM

      it { should report_lint count: 1, line: 3 }
    end
    context 'and the standalone output statement has appropriate spacing' do
      let(:slim) { <<~'SLIM' }
        div class="a \
         b"
          = foo
      SLIM

      it { should_not report_lint }
    end

    context 'and the standalone output statement is missing spacing' do
      let(:slim) { <<~'SLIM' }
        div class="a \
         b"
          =foo
      SLIM

      it { should report_lint count: 1, line: 3 }
    end
  end

  context 'when an output statement is not attached to a tag' do
    context 'and it has appropriate spacing' do
      let(:slim) { <<~'SLIM' }
        = ok
        == ok
        =< ok
        => ok
        ==<> ok
        = ok ==bad
      SLIM

      it { should_not report_lint }
    end

    context 'and it lacks spacing after =' do
      let(:slim) { '=bad' }

      it { should report_lint line: 1 }
    end

    context 'and it lacks spacing after ==' do
      let(:slim) { '==bad' }

      it { should report_lint line: 1 }
    end

    context 'and it lacks spacing after a whitespace modifier' do
      let(:slim) { <<~'SLIM' }
        =<bad
        =>bad
        ==<>bad
      SLIM

      it { should report_lint count: 3 }
    end

    context 'and it has too much spacing after =' do
      let(:slim) { '=  bad' }

      it { should report_lint }
    end

    context 'and it is nested in the block of another output statement' do
      let(:slim) { <<~'SLIM' }
        = form_for x do |f|
          =f.input :title
      SLIM

      it { should report_lint count: 1, line: 2 }
    end

    context 'and it is nested in a control statement' do
      let(:slim) { <<~'SLIM' }
        - if x
          =bad
      SLIM

      it { should report_lint count: 1, line: 2 }
    end

    context 'and its code spans multiple lines' do
      let(:slim) { <<~'SLIM' }
        = link_to 'Reset',
          url_for
      SLIM

      it { should_not report_lint }
    end
  end

  context 'when an output statement attached to a tag lacks spacing' do
    let(:slim) { 'div=bad' }

    it { should report_lint count: 1 }
  end

  context 'when space_before_output is disabled' do
    let(:config) { super().merge('space_before_output' => false) }

    context 'and there is no space before =' do
      let(:slim) { <<~'SLIM' }
        div= ok
        .some-class#submit==<> ok
        title= ok = 1
      SLIM

      it { should_not report_lint }
    end

    context 'and there is a space before =' do
      let(:slim) { 'div = bad' }

      it { should report_lint }
    end

    context 'and spacing is missing after =' do
      let(:slim) { 'div=bad' }

      it { should report_lint }
    end

    context 'and a standalone output statement lacks spacing' do
      let(:slim) { '=bad' }

      it { should report_lint }
    end
  end

  context 'autocorrect support' do
    let(:slim) { '' }

    it 'is declared' do
      described_class.supports_autocorrect?.should == true
    end
  end

  describe 'correction' do
    context 'for an output statement' do
      context 'with a missing space before =' do
        let(:slim) { 'div= bad = 1' }

        it 'adds the missing space' do
          subject.lints.first.correction.call('div= bad = 1')
                 .should == 'div = bad = 1'
        end
      end

      context 'with a missing space after =' do
        let(:slim) { 'div =bad = 1' }

        it 'adds the missing space' do
          subject.lints.first.correction.call('div =bad = 1')
                 .should == 'div = bad = 1'
        end
      end

      context 'with spaces missing on both sides of =' do
        let(:slim) { 'div=bad' }

        it 'adds the missing spaces' do
          subject.lints.first.correction.call('div=bad')
                 .should == 'div = bad'
        end
      end

      context 'with superfluous spacing around =' do
        let(:slim) { 'div  =  bad' }

        it 'collapses the spacing' do
          subject.lints.first.correction.call('div  =  bad')
                 .should == 'div = bad'
        end
      end

      context 'with attribute shortcuts' do
        let(:slim) { '.some-class#submit=bad' }

        it 'preserves the shortcuts' do
          subject.lints.first.correction.call('.some-class#submit=bad')
                 .should == '.some-class#submit = bad'
        end
      end

      context 'with a multi-character operator' do
        let(:slim) { 'title==<>bad' }

        it 'preserves the operator' do
          subject.lints.first.correction.call('title==<>bad')
                 .should == 'title ==<> bad'
        end
      end

      context 'when indented' do
        let(:slim) { "p\n  span= foo\n" }

        it 'only fixes spacing, preserving indentation' do
          subject.lints.first.correction.call('  span= foo')
                 .should == '  span = foo'
        end
      end

      context 'with an attribute containing =' do
        let(:slim) { 'a[href="x"]=bad' }

        it 'leaves the attribute untouched' do
          subject.lints.first.correction.call('a[href="x"]=bad')
                 .should == 'a[href="x"] = bad'
        end
      end

      context 'when applied via the corrector after a multi-line attribute' do
        let(:slim) { <<~'SLIM' }
          div class="a \
           b"
            span= foo
            =bar
        SLIM

        it 'fixes the lines holding the statements' do
          document = SlimLint::Document.new(normalize_indent(slim), config: config)
          subject.run(document)
          SlimLint::Corrector.new(document).correct(subject.lints)
                             .should == "div class=\"a \\\n b\"\n  span = foo\n  = bar\n"
        end
      end
    end

    context 'for an output statement not attached to a tag' do
      context 'with a missing space after =' do
        let(:slim) { '=bad' }

        it 'adds the missing space' do
          subject.lints.first.correction.call('=bad').should == '= bad'
        end
      end

      context 'with a multi-character operator' do
        let(:slim) { '==<>bad' }

        it 'preserves the operator' do
          subject.lints.first.correction.call('==<>bad').should == '==<> bad'
        end
      end

      context 'with superfluous spacing when indented' do
        let(:slim) { "p\n  =  bad == 1\n" }

        it 'collapses the spacing, preserving indentation' do
          subject.lints.first.correction.call('  =  bad == 1')
                 .should == '  = bad == 1'
        end
      end
    end

    context 'for an output statement when space_before_output is disabled' do
      let(:config) { super().merge('space_before_output' => false) }

      context 'with a space before =' do
        let(:slim) { 'div = bad = 1' }

        it 'removes it' do
          subject.lints.first.correction.call('div = bad = 1')
                 .should == 'div= bad = 1'
        end
      end

      context 'with attribute shortcuts and a multi-character operator' do
        let(:slim) { '.some-class#submit  ==<>bad' }

        it 'preserves the shortcuts and the operator' do
          subject.lints.first.correction.call('.some-class#submit  ==<>bad')
                 .should == '.some-class#submit==<> bad'
        end
      end

      context 'with an attribute containing =' do
        let(:slim) { 'a[href="x"] =  bad' }

        it 'leaves the attribute untouched' do
          subject.lints.first.correction.call('a[href="x"] =  bad')
                 .should == 'a[href="x"]= bad'
        end
      end
    end

    context 'for a control statement' do
      context 'with a missing space after -' do
        let(:slim) { '-bad' }

        it 'adds the missing space' do
          subject.lints.first.correction.call('-bad')
                 .should == '- bad'
        end
      end

      context 'with superfluous spacing after -' do
        let(:slim) { '-  bad' }

        it 'collapses the spacing' do
          subject.lints.first.correction.call('-  bad')
                 .should == '- bad'
        end
      end

      context 'when the code itself contains a hyphen' do
        let(:slim) { '-  something?("foo - bar")' }

        it 'only fixes the leading spacing' do
          subject.lints.first.correction.call('-  something?("foo - bar")')
                 .should == '- something?("foo - bar")'
        end
      end

      context 'when indented' do
        let(:slim) { "p\n  -bad\n" }

        it 'only fixes spacing, preserving indentation' do
          subject.lints.first.correction.call('  -bad')
                 .should == '  - bad'
        end
      end
    end
  end
end
