class CreateCarriers < ActiveRecord::Migration
  def change
    create_table :carriers do |t|
      t.string :code
      t.string :airline
      t.string :big_logo
      t.string :logo
      t.string :image

      t.timestamps null: false
    end
  end
end
