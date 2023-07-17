# frozen_string_literal: true

module Homework
  autoload :Helpers, File.expand_path('homework/helpers', __dir__)
  autoload :App, File.expand_path('homework/app', __dir__)
  autoload :API, File.expand_path('homework/api', __dir__)

  class << self
    def version
      File.read(File.expand_path('../VERSION', __dir__)).strip
    end

    def root
      File.expand_path('..', __dir__)
    end

    def public_path
      File.expand_path('../public', __dir__)
    end

    def logger
      @logger ||= Logger.new(STDOUT)
    end
  end
end
