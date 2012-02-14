class CreateItems < ActiveRecord::Migration
  def change
    create_table :items do |t|
      t.string      :title
      t.text        :description
      t.boolean     :paid, :default => false
      t.boolean     :published, :default => false
      t.references  :user
      
      t.timestamps
    end
			add_index :items, :user_id
  end
end
