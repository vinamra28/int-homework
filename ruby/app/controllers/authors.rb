# frozen_string_literal: true

class Homework::API::Authors < Grape::API
  version 'v1', using: :path
  resource :authors do
    helpers Homework::Helpers::ParamsHelper

    params do
      use :author
    end
    post do
      existingAuthor = Author.find_by(email: params[:author]['email'])
      if existingAuthor
        present existingAuthor
      else
        Author.create(declared(params)[:author])
      end
    end

    get do
      present Author.all
    end

    params do
      requires :author_id, type: Integer, desc: 'Author ID.'
    end
    route_param :author_id do
      get :delete do
        present current_author.destroy
      end

      put do
        curr_author = Author.find(params[:author_id])
        curr_author.full_name = params[:author]['full_name']
        curr_author.email = params[:author]['email']
        curr_author.save
      end
    end
  end
end
