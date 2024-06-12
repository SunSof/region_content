class PostsController < ApplicationController

  def all_region
    user = User.find(current_user.id)
    @posts = Post.where(region: user.region)
  end

  def all_user_posts
    @user = User.find(current_user.id)
    @posts = @user.posts.where(status:'approved')
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
      if params[:draft].present?
        @post.status = 'draft'
        redirect_to post_path(@post.id)
      elsif params[:pending_review].present?
        @post.status = 'pending_review'
        # send to admin
      end

    else
      render :new
    end
  end

  def drafts
    @user = User.find(current_user.id)
    @posts = @user.posts.where(status: 'draft')
  end

  def edit
  end

  private

  def post_params
    params.require(:post).permit(:title, :content, :user_id, :region, images: [], files:[] )
  end
end
