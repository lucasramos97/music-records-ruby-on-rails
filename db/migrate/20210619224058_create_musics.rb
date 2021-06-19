class CreateMusics < ActiveRecord::Migration[6.1]
  def change
    create_table :musics do |t|
      t.string :title, null: false
      t.string :artist, null: false
      t.date :release_date, null: false
      t.time :duration, null: false
      t.integer :number_views, default: 0
      t.boolean :feat, default: false
      t.boolean :deleted, default: false

      t.timestamps
    end
  end
end
