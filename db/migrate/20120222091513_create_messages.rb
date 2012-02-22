class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.references :user
      t.string :title
      t.text :body
      t.references :receiver

      t.timestamps
    end
    add_index :messages, :user_id
    add_index :messages, :receiver_id
  end
end
