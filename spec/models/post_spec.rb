require 'rails_helper'

RSpec.describe Post, type: :model do

  subject(:post) { FactoryBot.create(:post) }

  describe 'scopes' do
    let!(:region1) { create(:region) }
    let!(:region2) { create(:region) }
    let!(:user1) { create(:user) }
    let!(:user2) { create(:user) }
    let!(:post_in_region1) { create(:post, region: region1) }
    let!(:post_in_region2) { create(:post, region: region2) }
    let!(:post_by_user1) { create(:post, user: user1) }
    let!(:post_by_user2) { create(:post, user: user2) }
    let!(:post_published_today) { create(:post, published_at: DateTime.now) }

    context 'by_region' do
      it 'returns posts with the specified region_id' do
        expect(Post.by_region(region1.id)).to include(post_in_region1)
        expect(Post.by_region(region1.id)).not_to include(post_in_region2)
      end
    end

    context 'by_user' do
      it 'returns posts with the specified user_id' do
        expect(Post.by_user(user1.id)).to include(post_by_user1)
        expect(Post.by_user(user1.id)).not_to include(post_by_user2)
      end
    end

    context 'by_publish_date' do
      it 'returns posts published today' do
        start_date = DateTime.now.beginning_of_day
        end_date = DateTime.now.end_of_day
        expect(Post.by_publish_date(start_date, end_date)).to include(post_published_today)
      end

      it 'does not return posts published yesterday' do
        start_date = (DateTime.now - 1.day).beginning_of_day
        end_date = (DateTime.now - 1.day).end_of_day
        expect(Post.by_publish_date(start_date, end_date)).not_to include(post_published_today)
      end
    end
  end

  describe 'validations' do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:content) }
    it { should validate_presence_of(:region) }
    it { should validate_inclusion_of(:status).in_array(['draft', 'pending_review', 'approved', 'rejected']) }
  end

  describe 'filter' do
    let!(:region1) { create(:region) }
    let!(:region2) { create(:region) }
    let!(:user1) { create(:user) }
    let!(:user2) { create(:user) }
    let!(:posts) do
      [
        create(:post, title: 'Post 1', region: region1, user: user1, published_at: Time.zone.local(2023, 1, 1)),
        create(:post, title: 'Post 2', region: region1, user: user2, published_at: Time.zone.local(2023, 2, 1)),
        create(:post, title: 'Post 3', region: region2, user: user1, published_at: Time.zone.local(2023, 3, 1)),
        create(:post, title: 'Post 4', region: region2, user: user2, published_at: Time.zone.local(2023, 4, 1)),
      ]
    end

    it 'filters by region_id' do
      filtered_posts = described_class.filter(Post.all, region_id: region1.id)
      expect(filtered_posts.first.region_id).to eq(region1.id)
    end

    it 'filters by user_id' do
      filtered_posts = described_class.filter(Post.all, user_id: user1.id)
      expect(filtered_posts).to match_array(posts.select { |post| post.user_id == user1.id })
    end

    it 'filters by publish_date' do
      start_date = Time.zone.local(2023, 2, 1)
      end_date = Time.zone.local(2023, 4, 1)

      filtered_posts = described_class.filter(Post.all, start_date: start_date, end_date: end_date)
      expect(filtered_posts).to match_array(posts[1..3])
    end

    it 'returns all posts if no filters are provided' do
      filtered_posts = described_class.filter(Post.all, {})
      expect(filtered_posts).to match_array(posts)
    end
  end
end
