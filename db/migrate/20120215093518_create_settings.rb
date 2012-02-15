class CreateSettings < ActiveRecord::Migration
  def change
    create_table :settings do |t|
      t.string :key
      t.string :value
      t.string :description

      t.timestamps
    end
  end
end
