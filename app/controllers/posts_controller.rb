class PostsController < ApplicationController

  before_action :set_post, only: [:show, :submit_for_review, :approve, :reject, :destroy]
  before_action :load_posts, only: [:index]


  def index
    @posts = @posts.where( status: 'approved').order(published_at: :desc)
  end

  # def index
  #   @posts = Post.where( status: 'approved').order(published_at: :desc)
  #   @posts = @posts.by_region(params[:region_id]) if params[:region_id].present?
  #   @posts = @posts.by_user(params[:user_id]) if params[:user_id].present?
  #   if params[:start_date].present? && params[:end_date].present?
  #     @posts = @posts.by_publish_date(params[:start_date], params[:end_date])
  #   end
  # end

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

  def set_post
    @post = Post.find(params[:id])
  end

  def post_params
    params.require(:post).permit(:title, :content, :user_id, :region_id, images: [], files:[] )
  end
end
