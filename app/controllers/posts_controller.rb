class PostsController < ApplicationController

  before_action :set_post, only: [:show, :submit_for_review, :approve, :reject, :destroy]
  before_action :load_posts, only: [:index]


  def index
    @posts = @posts.where( status: 'approved').order(published_at: :desc)
    store_filters_in_session
  end

  def user_posts
    @user = User.find(current_user.id)
    @posts = @user.posts.where(status: ['approved', 'pending_review','rejected'])
  end

  def show
    @post = Post.find(params[:id])
  end

  def new
    @post = Post.new
  end

  def create
    @post = Post.new(post_params)
    if @post.save
      if params[:commit] == 'В черновики'
        UpdatePostStatusJob.perform_async(@post.id, 'draft')
        redirect_to drafts_path
      elsif params[:commit] == 'На модерацию'
        submit_for_review
      elsif params[:commit] == 'Опубликовать'
        approve
      else
        render :new
      end
    else
      render :new
    end
  end

  def submit_for_review
    UpdatePostStatusJob.perform_async(@post.id, 'pending_review')
    redirect_to user_posts_path
  end

  def approve
    UpdatePostStatusJob.perform_async(@post.id, 'approved')
    @post.update(published_at: Time.zone.now)
    flash[:notice] = "Пост одобрен"
    redirect_to pending_posts_for_review_path
  end

  def reject
    UpdatePostStatusJob.perform_async(@post.id, 'rejected')
    flash[:alert] = "Пост отклонен"
    pending_posts_for_review_path
  end

  def drafts
    @user = User.find(current_user.id)
    @posts = @user.posts.where(status: 'draft')
  end

  def destroy
    if @post.status == 'draft'
      @post.destroy
    end
    redirect_to drafts_path
  end

  def pending_posts_for_review
    @posts = Post.where(status: 'pending_review')
  end

  def generate_report
    load_posts_from_session
    respond_to do |format|
      format.xlsx do
        response.headers['Content-Disposition'] = 'attachment; filename="posts_report.xlsx"'
        render xlsx: "generate_report", filename: "posts_report.xlsx", locals: { posts: @posts }
      end
    end
    file_path = Rails.root.join("tmp", "posts_report.xlsx")
    send_file file_path, filename: "posts_report.xlsx", type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
  end

  private

  def load_posts
    @posts = Post.all
    apply_filters
  end

  def apply_filters
    @posts = @posts.by_region(params[:region_id]) if params[:region_id].present?
    @posts = @posts.by_user(params[:user_id]) if params[:user_id].present?
    apply_date_filters
  end

  def apply_date_filters
    if params[:start_date].present? && params[:end_date].present?
      start_date = params[:start_date].to_date
      end_date = params[:end_date].to_date
      @posts = @posts.by_publish_date(start_date, end_date)
    end
  end

  def store_filters_in_session
    session[:filters] = {
      region_id: params[:region_id],
      user_id: params[:user_id],
      start_date: params[:start_date],
      end_date: params[:end_date]
    }
  end

  def load_posts_from_session
    filters = session[:filters]
    @posts = Post.all.where( status: 'approved')
    if filters["region_id"].present?
      @posts = @posts.by_region(filters["region_id"].to_i)
    end

    if filters["user_id"].present?
      @posts = @posts.by_user(filters["user_id"].to_i)
    end

    apply_date_filters_from_session(filters["start_date"], filters["end_date"])

  end

  def apply_date_filters_from_session(start_date, end_date)
    if start_date.present? && end_date.present?
      start_date = start_date.to_date.beginning_of_day
      end_date = end_date.to_date.end_of_day
      @posts = @posts.by_publish_date(start_date, end_date)
    end

    @posts
  end


  def set_post
    @post = Post.find(params[:id])
  end

  def post_params
    params.require(:post).permit(:title, :content, :user_id, :region_id, images: [], files:[] )
  end
end
