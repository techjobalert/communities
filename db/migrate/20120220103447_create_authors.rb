class CreateAuthors < ActiveRecord::Migration
  def change
    create_table :authors do |t|
      t.user :references
      t.item :references

      t.timestamps
    end
  end
end
