ENV['RACK_ENV'] ||= 'test'

require File.expand_path('../config/environment', __dir__)
require 'database_cleaner/active_record'

FactoryBot.definition_file_paths = %w[./spec/factories]

Dir.glob('./spec/support/*.rb') do |file|
  require file
end

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.include FactoryBot::Syntax::Methods

  config.before(:suite) do
    Homework::App.instance.db_connection
    FactoryBot.find_definitions

    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end
end
