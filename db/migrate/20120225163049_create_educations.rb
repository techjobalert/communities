class CreateEducations < ActiveRecord::Migration
  def change
    create_table :educations do |t|
      t.string :country
      t.string :state
      t.string :city
      t.string :school
      t.date :from
      t.date :to
      t.references :user

      t.timestamps
    end
  end
end
