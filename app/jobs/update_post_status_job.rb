class UpdatePostStatusJob
  include Sidekiq::Job

  def perform(post_id, status)
    post = Post.find_by(id: post_id)
    return unless post

    post.update(status: status)
  end
end
