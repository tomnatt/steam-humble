class Game < ApplicationRecord
  validates :steam_appid, :game_name, presence: true, allow_nil: true
  validates :humble_bundle, presence: true
  validates :steam_appid, :game_name, uniqueness: true, allow_nil: true
  validates :steam_appid, numericality: { only_integer: true }, allow_nil: true
end
