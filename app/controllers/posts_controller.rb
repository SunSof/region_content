class PostsController < ApplicationController

  before_action :set_post, only: [:show, :submit_for_review, :approve, :reject, :destroy]

  def index
    @posts =
      Post
      .includes(:user, :region)
      .where( status: 'approved')
      .order(published_at: :desc)

      @posts = Post.filter(@posts, params)

      session[:filters] = {
      region_id: params[:region_id],
      user_id: params[:user_id],
      start_date: params[:start_date],
      end_date: params[:end_date]
      }
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

  def destroy
    if @post.status == 'draft'
      @post.destroy
    end
    redirect_to drafts_path
  end

  def user_posts
    @user = User.find(current_user.id)
    @posts = @user.posts.where(status: ['approved', 'pending_review','rejected'])
  end

  def submit_for_review
    UpdatePostStatusJob.perform_async(@post.id, 'pending_review')
    redirect_to user_posts_path
  end

  def drafts
    @user = User.find(current_user.id)
    @posts = @user.posts.where(status: 'draft')
  end

  def approve
    UpdatePostStatusJob.perform_async(@post.id, 'approved')
    @post.update(published_at: Time.zone.now)
    flash[:notice] = "Пост одобрен"
    redirect_to pending_posts_for_review_path
  end

  def reject
    UpdatePostStatusJob.perform_async(@post.id, 'rejected')
    flash[:notice] = "Пост отклонен"
    pending_posts_for_review_path
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

  def set_post
    @post = Post.find(params[:id])
  end

  def post_params
    params.require(:post).permit(:title, :content, :user_id, :region_id, images: [], files:[] )
  end

  def load_posts_from_session
    @posts =
      Post
      .includes(:user, :region)
      .where( status: 'approved')
      .order(published_at: :desc)

      region_id = session[:filters]["region_id"]
      user_id = session[:filters]["user_id"]
      start_date = session[:filters]["start_date"]
      end_date = session[:filters]["end_date"]

      filtering_params = {
        region_id: region_id.present? ? region_id.to_i : nil,
        user_id: user_id.present? ? user_id.to_i : nil,
        start_date: start_date,
        end_date: end_date
      }
      @posts = Post.filter(@posts, filtering_params)

  end
end
