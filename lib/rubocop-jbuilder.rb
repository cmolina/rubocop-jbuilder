# frozen_string_literal: true

require 'rubocop'

require_relative 'rubocop/jbuilder'
require_relative 'rubocop/jbuilder/version'
require_relative 'rubocop/jbuilder/inject'

RuboCop::Jbuilder::Inject.defaults!

require_relative 'rubocop/cop/jbuilder_cops'
