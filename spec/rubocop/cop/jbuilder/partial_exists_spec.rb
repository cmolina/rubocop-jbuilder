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
                      ^^^^^^^^^ Jbuilder/PartialExists: Partial not found. Looked for: app/views/testing/nested/_comment.json.jbuilder, app/views/testing/_comment.json.jbuilder
      RUBY
    end

    it "does not register an offense when partial exists" do
      expect_no_offenses(<<~RUBY)
        json.partial! 'exists'
      RUBY
    end
  end

  context 'with "json.property"' do
    it "register an offense when partial does not exist" do
      expect_offense(<<~RUBY)
        json.comments @comments, partial: 'comments/comment', as: :comment
                                          ^^^^^^^^^^^^^^^^^^ Jbuilder/PartialExists: Partial not found. Looked for: app/views/comments/_comment.json.jbuilder
      RUBY
    end

    it "register an offense when local partial does not exist" do
      expect_offense(<<~RUBY)
        json.comments @comments, partial: 'comment', as: :comment
                                          ^^^^^^^^^ Jbuilder/PartialExists: Partial not found. Looked for: app/views/testing/nested/_comment.json.jbuilder, app/views/testing/_comment.json.jbuilder
      RUBY
    end

    it "does not register an offense when partial exists" do
      expect_no_offenses(<<~RUBY)
        json.exists @exists, partial: 'exists', as: :exists
      RUBY
    end
  end
end
