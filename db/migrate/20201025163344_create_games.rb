class CreateGames < ActiveRecord::Migration[6.0]
  def change
    create_table :games do |t|
      t.integer :steam_appid
      t.string :game_name
      t.date :humble_bundle

      t.timestamps
    end
    add_index :games, :steam_appid, unique: true
  end
end
