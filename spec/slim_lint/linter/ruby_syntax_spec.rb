# frozen_string_literal: true

require 'spec_helper'

describe SlimLint::Linter::RubySyntax do
  include_context 'linter'

  context 'when a Ruby comment follows code output' do
    let(:slim) { <<-SLIM }
      ' Hello. This is some simple math:
      = 1 + 1 # this equals 2
    SLIM

    it { should report_lint line: 2 }

    it 'reports the syntax error' do
      subject.lints.first.message.should start_with 'Template compiles to invalid Ruby code: '
    end
  end

  context 'when the syntax error is in the middle of the template' do
    let(:slim) { <<-SLIM }
      p Hello
      - if user.admin?)
        p Admin
      p Bye
    SLIM

    it { should report_lint line: 2 }
  end

  context 'when a block is opened with a brace' do
    let(:slim) { <<-SLIM }
      - users.each { |user|
        p = user.name
      - }
    SLIM

    it { should report_lint line: 1 }
  end

  context 'when a control statement contains invalid Ruby' do
    let(:slim) { <<-SLIM }
      - user =
      p = user
    SLIM

    it { should report_lint }
  end

  context 'when an attribute contains invalid Ruby' do
    let(:slim) { <<-SLIM }
      a href=user_path(user +)
    SLIM

    it { should report_lint line: 1 }
  end

  context 'when interpolated Ruby is invalid' do
    let(:slim) { <<-SLIM }
      p Hello \#{user.name +}
    SLIM

    it { should report_lint line: 1 }
  end

  context 'when a ruby block contains invalid Ruby' do
    let(:slim) { <<-SLIM }
      ruby:
        users = [alice, bob
      p = users.size
    SLIM

    it { should report_lint }
  end

  context 'when the template is valid' do
    let(:slim) { <<-SLIM }
      doctype html
      html
        head
          title = page_title
          javascript:
            var user = "\#{user.name}";
          css:
            p { color: red; }
        body
          = yield
          - if user.admin?
            p Admin
          - elsif user.guest?
            p Guest
          - else
            p User
          - users.each do |user|
            = link_to user.name, user_path(user)
          = form_for user do |form|
            = form.text_field :name
          ruby:
            posts = user.posts.map do |post|
              post.title
            end
          p = posts.join(', ')
          a.button href=user_path(user,
                                  format: :json)
            | Show
          = link_to 'Edit', \\
            edit_user_path(user)
          p Hello \#{user.name}
          - user = User.new # Ruby comments are fine in control statements
          = user.name
    SLIM

    it { should_not report_lint }
  end

  context 'when the template contains engines rendered at compile time' do
    let(:slim) { <<-SLIM }
      markdown:
        # Hello \#{user.name}
      scss:
        p { color: $red; }
      coffee:
        alert 'Hello'
      p Bye
    SLIM

    it { should_not report_lint }
  end
end
