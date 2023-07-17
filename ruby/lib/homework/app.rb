# frozen_string_literal: true

class Homework::App
  include Singleton

  def initialize
    @filenames = ['', '.html', 'index.html', '/index.html']
    @rack_static = ::Rack::Static.new(
      -> { [404, {}, []] },
      root: Homework.public_path,
      urls: ['/']
    )
  end

  def self.rack
    Rack::Builder.new do
      use Rack::Cors do
        allow do
          origins '*'
          resource '*', headers: :any, methods: :get
        end
      end

      run Homework::App.instance
    end.to_app
  end

  def call(env)
    db_connection.verify!

    # api
    response = Homework::API.call(env)

    # Check if the App wants us to pass the response along to others
    if response[1]['X-Cascade'] == 'pass'
      # static files
      request_path = env['PATH_INFO']
      @filenames.each do |path|
        response = @rack_static.call(env.merge('PATH_INFO' => request_path + path))
        return response if response[0] != 404
      end
    end
    response
  rescue Exception => e
    Homework.logger.error e
    Homework.logger.error e.backtrace * "\n"
    raise e
  end

  def db_connection
    @db_connection ||= initialize_db_connection
    @db_connection
  end

  def db_create
    create_database if ENV['RACK_ENV'] != 'production'
  end

  def db_migrate
    db_connection.create_table(:articles, primary_key: 'id', force: true) do |t|
      t.string :title
      t.string :content
      t.string :created_at
    end

    db_connection.create_table(:authors, primary_key: 'id', force: true) do |t|
      t.string :full_name
      t.string :email
      t.string :created_at
    end

    db_connection.create_join_table(:articles, :authors)
  end

  def db_seed
    db_connection.verify!
    generate_authors
    generate_articles
  end

  protected

  def generate_authors
    rand(5..10).times do
      Author.create(
        full_name: Faker::Name.name,
        email: Faker::Internet.email(domain: 'test.anynines.com'),
        created_at: Time.now
      )
    end
    puts "Author count in DB: #{Author.count}"
  end

  def generate_articles
    rand(5..10).times do
      article = Article.create(
        title: Faker::Lorem.sentence,
        content: Faker::Lorem.paragraph,
        created_at: Time.now
      )
      article.authors = Author.all.sample(rand(1..2))
    end
    puts "Article count in DB: #{Article.count}"
  end

  def create_database
    initialize_db_connection(
      config: db_config.merge(database: nil)
    ).create_database(
      db_config[:database]
    )
  end

  def initialize_db_connection(config: db_config)
    ActiveRecord::Base.establish_connection(config)
    ActiveRecord::Base.connection
  end

  def db_config
    if ENV['VCAP_SERVICES']
      db_config_by_vcap
    else
      db_config_by_dotenv
    end
  end

  def db_config_by_vcap
    vcap_config = JSON.parse(ENV['VCAP_SERVICES'])
    vcap_db_config = vcap_config['a9s-postgresql10'].first['credentials']
    {
      adapter: 'postgresql',
      database: vcap_db_config['name'],
      host: vcap_db_config['host'],
      username: vcap_db_config['username'],
      password: vcap_db_config['password']
    }
  end

  def db_config_by_dotenv
    {
      adapter: 'postgresql',
      database: ENV['DB_NAME'],
      host: ENV['DB_HOST'],
      username: ENV['DB_USER'],
      password: ENV['DB_PASS']
    }
  end
end
