# frozen_string_literal: true

class Homework::API::Articles < Grape::API
  version 'v1', using: :path
  resource :articles do
    helpers Homework::Helpers::ParamsHelper

    params do
      use :article
    end
    post do
      present Article.create(declared(params)[:article])
    end

    get do
      present Article.all
    end

    params do
      requires :article_id, type: Integer, desc: 'Article ID.'
    end
    route_param :article_id do
      helpers do
        def current_article
          Article.find(declared(params)[:article_id])
        end
      end

      # deletes the article based on article ID
      get :delete do
        present current_article.destroy
      end

      params do
        use :article
      end
      put do
        present current_article.update(declared(params)[:article])
      end

      # Handles the request GET /api/v1/article/:article_id/author
      get '/authors' do
        article = Article.find(declared(params)[:article_id])
        present article.authors
      end

      # Handles the request POST /api/v1/article/:article_id/author
      params do
        requires :article_id, type: Integer, desc: 'Article ID.'
        use :author, type: Hash
      end
      post '/authors' do
        article = Article.find(declared(params)[:article_id])
        puts declared(params)[:author]
        author = Author.create(declared(params)[:author])
        article.authors << author
        present author
      end

      mount Homework::API::Authors
    end
  end
end
