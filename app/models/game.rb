class Game < ApplicationRecord
  validates :steam_appid, :game_name, :humble_bundle, presence: true
  validates :steam_appid, :game_name, uniqueness: true
  validates :steam_appid, numericality: { only_integer: true }
end
