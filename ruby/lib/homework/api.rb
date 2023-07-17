# frozen_string_literal: true

class Homework::API < Grape::API
  use Rack::SslEnforcer if %w[production staging].include?(ENV['RACK_ENV'])

  autoload :Articles, File.join(Homework.root, 'app', 'controllers', 'articles')
  autoload :Authors,  File.join(Homework.root, 'app', 'controllers', 'authors')

  logger.level = ENV['RACK_ENV'] == 'test' ? Logger::ERROR : Logger::INFO
  insert_after(
    Grape::Middleware::Formatter,
    Grape::Middleware::Logger,
    logger: logger
  )

  prefix 'api'
  format :json

  http_basic do |username, password|
    if ENV['USERNAME'] == username && ENV['PASSWORD'] == password
      Homework.logger.info('Authorized')
    else
      Homework.logger.info('Unauthorized')
    end
  end

  rescue_from Grape::Exceptions::ValidationErrors do |e|
    error!({ error: e.message }, 422)
  end

  rescue_from ActiveRecord::RecordNotFound do |e|
    error!({ error: e.message }, 404)
  end

  rescue_from :all do |e|
    Homework.logger.error e
    Homework.logger.error e.backtrace * "\n"
    error!({ error: 'internal server error' }, 500)
  end

  mount Homework::API::Articles
  mount Homework::API::Authors

  add_swagger_documentation(
    add_version: true,
    doc_version: Homework.version,
    hide_documentation_path: true,
    info: {
      title: 'Homework',
      description: File.read(File.join(Homework.root, 'README.md'))
    },
    security_definitions: {
      apiKey: {
        type: 'apiKey',
        in: 'header',
        name: 'Authorization'
      }
    },
    security: [{ basicAuth: [] }, { apiKey: [] }]
  )
end
