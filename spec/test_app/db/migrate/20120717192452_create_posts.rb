class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts, force: true do |t|
      t.string  :title
      t.integer :visits
      t.float   :conversion_rate
      t.date    :published_on
      t.datetime :expired_at
      t.boolean :published
      t.timestamp :unix_timestamp
      t.timestamps
    end
  end
end
