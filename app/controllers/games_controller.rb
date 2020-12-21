require "date"
require "google_drive"
require "json"
require "open-uri"

class GamesController < ApplicationController
  #skip_before_action :set_game,
  before_action :set_game, only: [:show, :edit, :update, :destroy, :update_local_db]

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
      if @game.update(game_params) && params[:commit] == "Update Steam ID"
        format.html { redirect_to @game, notice: 'Steam ID was successfully updated.' }
        format.json { render :show_steam_updated, status: :ok, location: @game }
      elsif @game.update(game_params)
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

  # DELETE /games/destroy_db
  def destroy_db
    @games = Game.all
    @games.destroy_all
    respond_to do |format|
      format.html { redirect_to games_url, notice: 'Games were successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  # GET /games/update_db
  def update_db
    cycle_through_humble_database_worksheets()
    respond_to do |format|
      format.html { redirect_to games_url, notice: 'Games were successfully added.' }
      format.json { head :no_content }
    end
  end

  # GET /games/show_failed_input
  def show_failed_input
    @games = Game.where(steam_appid: nil)
  end

  # GET /games/1/find_steam_id
  def find_steam_id
    @game = Game.find(params[:id])
    steam_hash_db = pull_steam_app_db()
    game_name_string = @game.game_name[0..5]
    @steam_id_options = steam_hash_db.select{ |k,v| k[game_name_string] }.to_a
  end

  def show_steam_updated
    @game = Game.find(params[:id])
  end

  private

  def pull_steam_app_db
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

  def pull_humble_database
    # A google API developer key is required
    session = GoogleDrive::Session.from_service_account_key(ENV['GOOGLE_API_KEY'])
    humble_spreadsheet = "1Y5ySEXPLZdmKFNdMOrGlCEVl6nb_G0X3nYCFSWIdktY"
    return ws_spreadsheet = session.spreadsheet_by_key(humble_spreadsheet)
  end

  def cycle_through_humble_database_worksheets
    steam_hash_db = pull_steam_app_db()
    ws_spreadsheet = pull_humble_database()
    ws = ws_spreadsheet.worksheets[0]

    #(0..ws_spreadsheet.worksheets.size - 1) each do |spreadsheet|

    (2..ws.num_rows).each do |row|

      # date of humble bundle
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



  # Use callbacks to share common setup or constraints between actions.
  def set_game
    @game = Game.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def game_params
    params.require(:game).permit(:steam_appid, :game_name, :humble_bundle)
  end

end
