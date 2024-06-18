class CreatePosts < ActiveRecord::Migration[7.1]
  def change
    create_table :posts do |t|
      t.string :title
      t.text :content
      t.string :status
      t.datetime :published_at, index: true
      t.references :user, null: false, foreign_key: true, index: true
      t.references :region, null: false, foreign_key: true, index: true

      t.timestamps
    end
  end
end
