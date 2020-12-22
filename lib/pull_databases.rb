require "date"
require "google_drive"
require "json"
require "open-uri"

class PullDatabase
  def self.pull_steam_app_db
    uri = URI.open('http://api.steampowered.com/ISteamApps/GetAppList/v0002/')
    steam_json_file = JSON.parse uri.read
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

  def self.pull_humble_database
    # A google API developer key is required
    session = GoogleDrive::Session.from_service_account_key(ENV['GOOGLE_API_KEY'])
    humble_spreadsheet = "1Y5ySEXPLZdmKFNdMOrGlCEVl6nb_G0X3nYCFSWIdktY"
    return ws_spreadsheet = session.spreadsheet_by_key(humble_spreadsheet)
  end

  def self.cycle_through_humble_database_worksheets
    steam_hash_db = pull_steam_app_db()
    ws_spreadsheet = pull_humble_database()

    ws = ws_spreadsheet.worksheets[0]
    #(0..ws_spreadsheet.worksheets.size - 1) each do |spreadsheet|

    (2..ws.num_rows).each do |row|

      # date of humble bundle - add skip function
      date = Date.parse(ws[row, 1]).to_date.to_s

      # early unlock games
      (2..4).each do |col|
        games_to_input = ws[row, col].split(', ').map(&:strip)

        if games_to_input[0] == "N/A" # Skips empty bundles
        else
          (0..games_to_input.size-1).each do |item|
            humble_game_name = games_to_input[item]
            steam_id = steam_hash_db[humble_game_name]

            @game = Game.new(game_name: humble_game_name, humble_bundle: date, steam_appid: steam_id)
            @game.save
          end
        end
      end
    end
  end

end
