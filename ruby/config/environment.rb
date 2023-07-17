# frozen_string_literal: true

ENV['RACK_ENV'] ||= 'development'

unless %w[production staging].include?(ENV['RACK_ENV'])
  require 'dotenv'

  Dotenv.load(
    File.expand_path(
      '../.env',
      __dir__
    )
  )
end
require File.expand_path('application', __dir__)
