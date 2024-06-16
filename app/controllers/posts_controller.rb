class PostsController < ApplicationController

  before_action :set_post, only: [:show, :approve, :reject]

  def all_region
    user = User.find(current_user.id)
    @posts = Post.where(region: user.region)
  end

  def all_user_posts
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
        UpdatePostStatusJob.perform_async(@post.id, 'pending_review')
        redirect_to all_user_posts_path
      else
        render :new
      end
    else
      render :new
    end
  end

  def approve
    UpdatePostStatusJob.perform_async(@post.id, 'approved')
  end

  def reject
    UpdatePostStatusJob.perform_async(@post.id, 'rejected')
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
    params.require(:post).permit(:title, :content, :user_id, :region, images: [], files:[] )
  end
end
