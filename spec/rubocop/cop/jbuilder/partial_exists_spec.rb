# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Jbuilder::PartialExists, :config do
  let(:config) { RuboCop::Config.new }

  context 'with "json.partial!"' do
    it "register an offense when partial does not exist" do
      expect_offense(<<~RUBY)
        json.partial! 'comments/comment', comments: @message.comment
                      ^^^^^^^^^^^^^^^^^^ Jbuilder/PartialExists: Partial not found. Looked for: app/views/comments/_comment.json.jbuilder
      RUBY
    end

    it "register an offense when local partial does not exist" do
      expect_offense(<<~RUBY)
        json.partial! 'comment', comments: @message.comment
                      ^^^^^^^^^ Jbuilder/PartialExists: Partial not found. Looked for: app/views/testing/_comment.json.jbuilder
      RUBY
    end

    it "does not register an offense when partial exists" do
      expect_no_offenses(<<~RUBY)
        json.partial! 'exists'
      RUBY
    end
  end

  context 'with "json.partial! partial:"' do
    it "register an offense when partial does not exist" do
      expect_offense(<<~RUBY)
        json.partial! partial: 'comments/comment', comments: @message.comment
                               ^^^^^^^^^^^^^^^^^^ Jbuilder/PartialExists: Partial not found. Looked for: app/views/comments/_comment.json.jbuilder
      RUBY
    end

    it "register an offense when local partial does not exist" do
      expect_offense(<<~RUBY)
        json.partial! partial: 'comment', comments: @message.comment
                               ^^^^^^^^^ Jbuilder/PartialExists: Partial not found. Looked for: app/views/testing/_comment.json.jbuilder
      RUBY
    end

    it "does not register an offense when partial exists" do
      expect_no_offenses(<<~RUBY)
        json.partial! partial: 'exists'
      RUBY
    end
  end

  context 'with "json.array!"' do
    it "register an offense when partial does not exist" do
      expect_offense(<<~RUBY)
        json.array! @comments, partial: 'comments/comment', as: :comment
                                        ^^^^^^^^^^^^^^^^^^ Jbuilder/PartialExists: Partial not found. Looked for: app/views/comments/_comment.json.jbuilder
      RUBY
    end

    it "register an offense when local partial does not exist" do
      expect_offense(<<~RUBY)
        json.array! @comments, partial: 'comment', as: :comment
                                        ^^^^^^^^^ Jbuilder/PartialExists: Partial not found. Looked for: app/views/testing/_comment.json.jbuilder
      RUBY
    end

    it "does not register an offense when partial exists" do
      expect_no_offenses(<<~RUBY)
        json.array! @exists, partial: 'exists', as: :exists
      RUBY
    end
  end
end
