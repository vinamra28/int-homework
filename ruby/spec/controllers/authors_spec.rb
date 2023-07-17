require 'spec_helper'

describe Homework::API::Authors do
  include Rack::Test::Methods

  let(:app) { Homework::App.instance }
  let(:auth_header) { prepare_headers(HeaderType::HTTP_AUTH) }
  let(:email_type_header) { prepare_headers(HeaderType::CONTENT_TYPE) }

  let(:author) { FactoryBot.create(:author) }
  let(:author_attributes) { FactoryBot.attributes_for(:author) }

  describe 'GET /' do
    let(:response) { get '/api/v1/authors', nil, auth_header }

    it 'returns an persisted author' do
      expect(author).to be_persisted
      expect(response.status).to eq 200
      hashed_response = JSON.parse(response.body)
      expect(hashed_response.length).to eq(1)
    end
  end

  describe 'POST /' do
    let(:response) do
      post(
        '/api/v1/authors',
        JSON.generate(author: author_attributes),
        prepare_headers
      )
    end

    it 'creates a new author' do
      expect(response.status).to eq 201
      hashed_response = JSON.parse(response.body)
      expect(hashed_response).to have_key('email')
      expect(hashed_response['email']).to eq(author_attributes[:email])
      expect(hashed_response).to have_key('full_name')
      expect(hashed_response['full_name']).to eq(author_attributes[:full_name])
    end
  end

  describe 'PUT /:author_id' do
    let(:response) do
      put "/api/v1/authors/#{author.id}", JSON.generate(author: author_attributes), prepare_headers
    end

    it 'updates an persisted author' do
      expect(response.status).to eq 200
      expect(JSON.parse(response.body)).to be(true)
      author.reload

      expect(author.email).to eq(author_attributes[:email])
      expect(author.full_name).to eq(author_attributes[:full_name])
    end
  end

  describe 'GET /:author_id/delete' do
    let(:response) { get "/api/v1/authors/#{author.id}/delete", nil, auth_header }

    it 'deletes a given author' do
      expect(response.status).to eq 200
      expect(Author.exists?(author.id)).to be(false)
    end

    context 'with wrong id' do
      let(:response) { get '/api/v1/authors/99/delete', nil, auth_header }

      it 'returns 404' do
        expect(response.status).to eq 404
        hashed_response = JSON.parse(response.body)
        expect(hashed_response).to have_key('error')
        expect(hashed_response['error']).to eq("Couldn't find Author with 'id'=99")
      end
    end
  end
end
