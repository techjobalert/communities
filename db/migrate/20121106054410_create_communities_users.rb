class CreateCommunitiesUsers < ActiveRecord::Migration
  def up
    create_table :communities_users do |t|
      t.integer :community_id
      t.integer :user_id
    end
  end

  def down
    drop_table :communities_users
  end
end
