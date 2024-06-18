module Filterable
  extend ActiveSupport::Concern

  module ClassMethods
    def filter(query, params)
      posts = params[:region_id].present? ? query.by_region(params[:region_id]) : query
      posts = params[:user_id].present? ? posts.by_user(params[:user_id]) : posts
      if params[:start_date].present? && params[:end_date].present?
        start_date = params[:start_date].to_date
        end_date = params[:end_date].to_date
        posts = posts.by_publish_date(start_date, end_date)
      else
        posts
      end
      posts
    end
  end
end
