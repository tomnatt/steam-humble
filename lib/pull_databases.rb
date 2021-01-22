require 'date'
require 'google_drive'
require 'json'
require 'open-uri'

# rubocop:disable Metrics/BlockLength
class PullDatabase
  def self.pull_steam_app_db
    uri = URI.open('http://api.steampowered.com/ISteamApps/GetAppList/v0002/')
    steam_json_file = JSON.parse uri.read
    steam_json_file_raw = steam_json_file['applist']['apps']
    steam_data = {}

    steam_json_file_raw.each do |app|
      if app.nil?
      else
        steam_data[app['name']] = app['appid']
      end
    end

    steam_data
  end

  def self.pull_humble_database
    # A google API developer key is required
    session = GoogleDrive::Session.from_service_account_key(ENV['GOOGLE_API_KEY'])
    humble_spreadsheet = '1Y5ySEXPLZdmKFNdMOrGlCEVl6nb_G0X3nYCFSWIdktY'
    session.spreadsheet_by_key(humble_spreadsheet)
  end

  def self.rebuild_database(incoming_date)
    if incoming_date == 1
      last_date = incoming_date.to_i
    else
      last_date = incoming_date.to_time.to_i
    end

    number_of_games = 0
    game_errors = []

    steam_hash_db = pull_steam_app_db
    ws_spreadsheet = pull_humble_database

    ws = ws_spreadsheet.worksheets[1]

    (2..ws.num_rows).each do |row|
      date = Date.parse(ws[row, 1]).to_date.to_s
      next if last_date >= Date.parse(ws[row, 1]).to_time.to_i

      games_to_input = ws[row, 2].split('; ').map(&:strip)

      # Takes name and removes money part
      games_to_input.each do |item|
        name_and_cost = item.split(' ')
        name_and_cost.pop
        humble_game_name = name_and_cost.join(' ')
        steam_id = steam_hash_db[humble_game_name]

        @game = Game.new(game_name: humble_game_name, humble_bundle: date, steam_appid: steam_id)
        if @game.save
          number_of_games = number_of_games + 1
        else
          game_errors.push(@game)
        end
      end
    end

    if last_date == 1
      ws = ws_spreadsheet.worksheets[0]
      (2..ws.num_rows).each do |row|
        date = Date.parse(ws[row, 1]).to_date.to_s

        # All games - excludes comics and other columns on humble sheet
        (2..4).each do |col|
          games_to_input = ws[row, col].split('; ').map(&:strip)

          if games_to_input[0] == 'N/A' # Skips empty bundles
          else
            games_to_input.each do |item|
              humble_game_name = item
              steam_id = steam_hash_db[item]

              @game = Game.new(game_name: humble_game_name, humble_bundle: date, steam_appid: steam_id)
              if @game.save
                number_of_games = number_of_games + 1
              else
                game_errors.push(@game)
              end
            end
          end
        end
      end
    end

    [number_of_games, game_errors]
  end

  def self.steam_id_options_creator(game_name)
    steam_hash_db = pull_steam_app_db
    if game_name == ''
      steam_id_options = []
    else
      game_name_string = game_name.split(' ').shift
      steam_id_options = steam_hash_db.select { |k, _v| k[game_name_string] }.sort_by { |k, _v| k }
      if steam_id_options.blank?
        game_name_string = game_name[1..4]
        steam_id_options = steam_hash_db.select { |k, _v| k[game_name_string] }.sort_by { |k, _v| k }
      end
    end

    steam_id_options.unshift(['Leave blank', nil])
  end
end
# rubocop:enable Metrics/BlockLength
