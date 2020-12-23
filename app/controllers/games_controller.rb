require "date"
require "google_drive"
require "json"
require "open-uri"
require 'pull_databases'

class GamesController < ApplicationController
  #skip_before_action :set_game,
  before_action :set_game, only: [:show, :edit, :update, :destroy, :update_local_db]

  # GET /games
  # GET /games.json
  def index
    if params[:view_param] == 'failed-db'
      @games = Game.where(steam_appid: nil)
    else
      @games = Game.all
    end
  end

  # GET /games/1
  # GET /games/1.json
  def show;
    @game = Game.find(params[:id])
    steam_hash_db = PullDatabase.pull_steam_app_db()
    game_name_string = @game.game_name[0..4]
    @steam_id_options = steam_hash_db.select{ |k,v| k[game_name_string] }.to_a
  end

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
        format.json { render :show, status: :ok, location: @game }
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
    PullDatabase.cycle_through_humble_database_worksheets()
    respond_to do |format|
      format.html { redirect_to games_url, notice: 'Games were successfully added.' }
      format.json { head :no_content }
    end
  end

  # GET /games/1/find_steam_id
  def find_steam_id
    @game = Game.find(params[:id])
    steam_hash_db = PullDatabase.pull_steam_app_db()
    game_name_string = @game.game_name[0..4]
    @steam_id_options = steam_hash_db.select{ |k,v| k[game_name_string] }.to_a
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_game
    @game = Game.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def game_params
    params.require(:game).permit(:steam_appid, :game_name, :humble_bundle)
  end

end
