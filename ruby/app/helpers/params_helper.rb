module Homework::Helpers::ParamsHelper
  extend Grape::API::Helpers

  params :article do
    requires :article, type: Hash, documentation: { param_type: 'body' } do
      requires :title,       type: String, allow_blank: false
      requires :content,     type: String, allow_blank: false
      optional :author_ids,  type: Array[Integer]
    end
  end

  params :author do
    requires :author, type: Hash, documentation: { param_type: 'body' } do
      requires :full_name, type: String, allow_blank: false
      requires :email, type: String, allow_blank: false
    end
  end

  def current_author
    Author.find(declared(params)[:author_id])
  end
end
