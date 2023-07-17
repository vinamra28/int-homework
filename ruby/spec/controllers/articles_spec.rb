require 'spec_helper'

describe Homework::API::Articles do
  include Rack::Test::Methods

  let(:app) { Homework::App.instance }
  let(:auth_header) { prepare_headers(HeaderType::HTTP_AUTH) }
  let(:content_type_header) { prepare_headers(HeaderType::CONTENT_TYPE) }

  let(:article) { FactoryBot.create(:article) }
  let(:article_attributes) { FactoryBot.attributes_for(:article) }

  describe 'authorization' do
    context 'without username and password' do
      it 'returns status 401' do
        response = get('/api/v1/articles', nil, {})
        expect(response.status).to eq 401
      end
    end

    context 'with wrong username and password' do
      let(:auth_header) do
        generate_auth_headers(
          user: 'John',
          password: 'Doe'
        )
      end
      it 'returns status 401' do
        response = get('/api/v1/articles', nil, auth_header)
        expect(response.status).to eq 401
      end
    end
  end
  describe 'GET /' do
    let(:response) { get '/api/v1/articles', nil, auth_header }

    it 'returns an persisted article' do
      expect(article).to be_persisted
      expect(response.status).to eq 200
      hashed_response = JSON.parse(response.body)
      expect(hashed_response.length).to eq(1)
    end
  end

  describe 'POST /' do
    let(:response) do
      post(
        '/api/v1/articles',
        JSON.generate(article: article_attributes),
        prepare_headers
      )
    end

    it 'creates a new article' do
      expect(response.status).to eq 201
      hashed_response = JSON.parse(response.body)
      expect(hashed_response).to have_key('content')
      expect(hashed_response['content']).to eq(article_attributes[:content])
      expect(hashed_response).to have_key('title')
      expect(hashed_response['title']).to eq(article_attributes[:title])
    end
  end

  describe 'PUT /:article_id' do
    let(:response) do
      put "/api/v1/articles/#{article.id}", JSON.generate(article: article_attributes), prepare_headers
    end

    it 'updates an persisted article' do
      expect(response.status).to eq 200
      expect(JSON.parse(response.body)).to be(true)
      article.reload

      expect(article.content).to eq(article_attributes[:content])
      expect(article.title).to eq(article_attributes[:title])
    end
  end

  describe 'GET /:article_id/delete' do
    let(:response) { get "/api/v1/articles/#{article.id}/delete", nil, auth_header }

    it 'deletes a given article' do
      expect(response.status).to eq 200
      expect(Article.exists?(article.id)).to be(false)
    end

    context 'with wrong id' do
      let(:response) { get '/api/v1/articles/99/delete', nil, auth_header }

      it 'returns 404' do
        expect(response.status).to eq 404
        hashed_response = JSON.parse(response.body)
        expect(hashed_response).to have_key('error')
        expect(hashed_response['error']).to eq("Couldn't find Article with 'id'=99")
      end
    end
  end

  context 'nested authors' do
    describe 'GET /:article_id/authors' do
      let!(:author) { FactoryBot.create(:author) }
      let!(:article_author) { FactoryBot.create(:author, articles: [article]) }
      let(:response) { get "/api/v1/articles/#{article.id}/authors", nil, auth_header }

      it 'returns only assigned authors' do
        expect(response.status).to eq 200
        hashed_response = JSON.parse(response.body)
        expect(hashed_response.length).to eq(1)
        expect(hashed_response.first['email']).to eq(article_author.email)
      end
    end

    describe 'POST /:article_id/authors' do
      let(:author_attributes) { FactoryBot.attributes_for(:author) }

      let(:response) do
        post(
          "/api/v1/articles/#{article.id}/authors",
          JSON.generate(author: author_attributes),
          prepare_headers
        )
      end

      it 'create a new author, assigned to the article' do
        expect(response.status).to eq 201
        hashed_response = JSON.parse(response.body)
        expect(hashed_response['email']).to eq(author_attributes[:email])
        expect(article.authors.count).to be(1)
      end
    end
  end
end
