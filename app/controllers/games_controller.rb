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

  def pull_humble_database()
    # A google API developer key is required
    session = GoogleDrive::Session.from_service_account_key(ENV['GOOGLE_API_KEY'])
    humble_spreadsheet = "1Y5ySEXPLZdmKFNdMOrGlCEVl6nb_G0X3nYCFSWIdktY"
    return ws_spreadsheet = session.spreadsheet_by_key(humble_spreadsheet)
  end

  def cycle_through_humble_database_worksheets()
    steam_hash_db = pull_steam_app_db()
    ws_spreadsheet = pull_humble_database()
    ws = ws_spreadsheet.worksheets[0]

    # test1 = ws[2, 2].split(', ').map(&:strip)
    # test2 = Date.parse(ws[2, 1]).to_date.to_s
    # test3 = "122"
    # @game = Game.new(game_name: test1[0], humble_bundle: test2, steam_appid: test3)
    # @game.save

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

      # # other games
      # other_games = ws[row, 3].split(', ').map(&:strip)
      #
      # #if other_games.size > 1
      #   (0..other_games.size-1).each do |game|
      #     steam_appid = nil
      #     game = other_games[game]
      #     game_data.push({date: date, game: game, steam_appid: steam_appid})
      #   end
      #
      # # humble originals
      # humble_origs = ws[row, 4].split(', ').map(&:strip)
      #
      # if humble_origs.size == 1 && humble_origs[0] = "N/A" # skips bundles with no originals
      # else
      #   (0..humble_origs.size-1).each do |game|
      #     steam_appid = nil
      #     game = humble_origs[game]
      #     game_data.push({date: date, game: game, steam_appid: steam_appid})
      #   end
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
