class AddUserToMusics < ActiveRecord::Migration[6.1]
  def change
    add_reference :musics, :user, null: false, foreign_key: true
  end
end
