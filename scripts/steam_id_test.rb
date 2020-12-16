require "date"
require "google_drive"
require "json"
require "open-uri"


def pull_steam_app_db
  uri = 'http://api.steampowered.com/ISteamApps/GetAppList/v0002/'
  steam_json_file = JSON.parse open(uri).read
  steam_json_file_raw = steam_json_file['applist']['apps']

  steam_data = {}

  (0..steam_json_file_raw.size).each do |app|
    if steam_json_file_raw[app].nil?
    else
      steam_data[steam_json_file_raw[app]['name']] = steam_json_file_raw[app]['appid']
    end
  end

  return steam_data
end

# requires a google API key
def pull_humble_database
  session = GoogleDrive::Session.from_service_account_key(ENV['GOOGLE_API_KEY'])
  humble_spreadsheet = "1Y5ySEXPLZdmKFNdMOrGlCEVl6nb_G0X3nYCFSWIdktY"
  ws = session.spreadsheet_by_key(humble_spreadsheet).worksheets[0]

  game_data = []

  (2..ws.num_rows).each do |row|
    # date of humble bundle
    date = Date.parse(ws[row, 1]).to_date.to_s

    # early unlock games
    early_unlock = ws[row, 2].split(', ').map(&:strip)

    if early_unlock.size > 1
      (0..early_unlock.size-1).each do |game|
        steam_appid = 1
        game = early_unlock[game]
        game_data.push({date: date, game: game, steam_appid: steam_appid})
      end

    else
      steam_appid = 1
      game = early_unlock[0]
      game_data.push({date: date, game: game, steam_appid: steam_appid})
    end

    # other games
    other_games = ws[row, 3].split(', ').map(&:strip)

    if other_games.size > 1
      (0..other_games.size-1).each do |game|
        steam_appid = 1
        game = other_games[game]
        game_data.push({date: date, game: game, steam_appid: steam_appid})
      end

    else
      steam_appid = 1
      game = other_games[0]
      game_data.push({date: date, game: game, steam_appid: steam_appid})
    end

    # humble originals
    humble_origs = ws[row, 4].split(', ').map(&:strip)

    if humble_origs.size > 1
      (0..humble_origs.size-1).each do |game|
        steam_appid = 1
        game = humble_origs[game]
        game_data.push({date: date, game: game, steam_appid: steam_appid})
      end

    elsif humble_origs.size == 1 && humble_origs[0] = "N/A" # skips bundles with no originals
    else
      steam_appid = 1
      game = humble_origs[0]
      game_data.push({date: date, game: game, steam_appid: steam_appid})
    end

  end

  return game_data
end

def assign_steamid_to_humble_games(steam_id_hash, humble_games_list)
  (0..humble_games_list.size-1).each do |model|
    humble_games_list[model][:steam_appid] = steam_id_hash[humble_games_list[model][:game]]
  end

  return humble_games_list
end

steam_id_db = pull_steam_app_db()
humble_id_db = pull_humble_database()
final_list = assign_steamid_to_humble_games(steam_id_db, humble_id_db)

# Still to do
# Known issue with some game names due to  - will need to fix
# Still need to pull data from second worksheet and adapt as necessary
