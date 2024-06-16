class UpdatePostStatusJob
  include Sidekiq::Job

  def perform(post_id, status)
    p post = Post.find_by(id: post_id)
    return unless post

    post.update(status: status)
    p post
  end
end
