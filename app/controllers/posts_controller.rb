class PostsController < ApplicationController

  before_action :set_post, only: [:show, :submit_for_review, :approve, :reject]

  def index_by_region
    user = User.find(current_user.id)
    @posts = Post.where( status: 'approved')
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

  def edit
  end

  def all_review_posts
    @posts = Post.where(status: 'pending_review')
  end

  private

  def set_post
    @post = Post.find(params[:id])
  end

  def post_params
    params.require(:post).permit(:title, :content, :user_id, :region_id, images: [], files:[] )
  end
end
