class GamesController < ApplicationController
  before_action :set_game, only: [:show, :edit, :update, :destroy]
  require "google_drive"
  require "date"
  # GET /games
  # GET /games.json
  def index
    @games = Game.all
  end

  # GET /games/1
  # GET /games/1.json
  def show; end

  # GET /games/new
  def new
    @game = Game.new
  end

  # GET /games/1/edit
  def edit; end

  # POST /games
  # POST /games.json
  def create
    steam_id_hash = pull_steam_app_db()
    humble_games_list = pull_humble_database()
    final_list = assign_steamid_to_humble_games(steam_id_hash, humble_games_list)

    (0..final_list.size-1).each do |game|
      @game = game_params
    @game = Game.new(game_params)

    respond_to do |format|
      if @game.save
        format.html { redirect_to @game, notice: 'Game was successfully created.' }
        format.json { render :show, status: :created, location: @game }
      else
        format.html { render :new }
        format.json { render json: @game.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /games/1
  # PATCH/PUT /games/1.json
  def update
    respond_to do |format|
      if @game.update(game_params)
        format.html { redirect_to @game, notice: 'Game was successfully updated.' }
        format.json { render :show, status: :ok, location: @game }
      else
        format.html { render :edit }
        format.json { render json: @game.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /games/1
  # DELETE /games/1.json
  def destroy
    @game.destroy
    respond_to do |format|
      format.html { redirect_to games_url, notice: 'Game was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  def pull_humble_database

    session = GoogleDrive::Session.from_service_account_key(ENV['GOOGLE_API_KEY'])

    humble_spreadsheet = "1Y5ySEXPLZdmKFNdMOrGlCEVl6nb_G0X3nYCFSWIdktY"
    ws = session.spreadsheet_by_key(humble_spreadsheet).worksheets[0]

    srand(777)
    game_data = []

    (2..ws.num_rows).each do |row|
      # date of humble bundle
      date = Date.parse(ws[row, 1]).to_date.to_s

      # early unlock games
      early_unlock = ws[row, 2].split(', ').map(&:strip)

      if early_unlock.size > 1
        (0..early_unlock.size-1).each do |game|
          steam_appid = (rand() * 10000).to_i
          game = early_unlock[game]
          game_data.push({date: date, game: game, steam_appid: steam_appid})
        end
      else
        steam_appid = (rand() * 10000).to_i
        game = early_unlock[0]
        game_data.push({date: date, game: game, steam_appid: steam_appid})
      end

      # other games
      other_games = ws[row, 3].split(', ').map(&:strip)

      if other_games.size > 1
        (0..other_games.size-1).each do |game|
          steam_appid = (rand() * 10000).to_i
          game = other_games[game]
          game_data.push({date: date, game: game, steam_appid: steam_appid})
          #all_early_unlocks.push(other_games[game])
          #p all_early_unlocks
        end
      else
        steam_appid = (rand() * 10000).to_i
        game = other_games[0]
        game_data.push({date: date, game: game, steam_appid: steam_appid})
      end

      # humble originals
      humble_origs = ws[row, 4].split(', ').map(&:strip)

      if humble_origs.size > 1
        (0..humble_origs.size-1).each do |game|
          steam_appid = (rand() * 10000).to_i
          game = humble_origs[game]
          game_data.push({date: date, game: game, steam_appid: steam_appid})
        end

      elsif humble_origs.size == 1 && humble_origs[0] = "N/A" # skips bundles with no originals

      else
        steam_appid = (rand() * 10000).to_i
        game = humble_origs[0]
        game_data.push({date: date, game: game, steam_appid: steam_appid})
      end

    end

    return game_data
  end

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

  def assign_steamid_to_humble_games(steam_id_hash, humble_games_list)
    (0..humble_games_list.size-1).each do |model|
      humble_games_list[model][:steam_appid] = steam_id_hash[humble_games_list[model][:game]]
    end

    return humble_games_list
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_game
    @game = Game.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def game_params
    params.require(:game).permit(:steam_appid, :game_name, :humble_bundle)
  end
end
