json.extract! game, :id, :steam_appid, :game_name, :humble_bundle, :created_at, :updated_at
json.url game_url(game, format: :json)
