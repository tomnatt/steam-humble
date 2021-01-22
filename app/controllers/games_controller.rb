require 'date'
require 'google_drive'
require 'json'
require 'open-uri'
require 'pull_databases'

class GamesController < ApplicationController
  before_action :set_game, only: [:show, :edit, :update, :destroy]

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
  def show; end

  # GET /games/new
  def new
    @steam_id_options = [['Leave blank', nil]]
    @game = Game.new
  end

  # GET /games/1/edit
  def edit
    @game = Game.find(params[:id])
    @steam_id_options = PullDatabase.steam_id_options_creator(@game.game_name)
  end

  # POST /games
  # POST /games.json
  def create
    @game = Game.new(game_params)

    respond_to do |format|
      if @game.save && params[:game][:steam_appid].blank?
        format.html { redirect_to edit_game_url(@game), notice: 'Select a Steam ID.' }
        format.json { render :edit, status: :created, location: @game }
      elsif @game.save
        format.html { redirect_to @game, notice: 'Game was successfully created.' }
        format.json { render :show, status: :created, location: @game }
      else
        @steam_id_options = PullDatabase.steam_id_options_creator('')
        format.html { render :new }
        format.json { render json: @game.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /games/1
  # PATCH/PUT /games/1.json
  def update
    if params[:game][:steam_appid_list].blank?
    else
      params[:game][:steam_appid] = params[:game][:steam_appid_list]
    end

    respond_to do |format|
      if @game.update(game_params)
        format.html { redirect_to @game, notice: 'Game was successfully updated.' }
        format.json { render :show, status: :ok, location: @game }
      else
        @steam_id_options = PullDatabase.steam_id_options_creator('')
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

  # GET /games/rebuild_db
  def rebuild_db
    variable_returned = PullDatabase.rebuild_database(1)
    failed_games = variable_returned[1]
    @number_of_failed_games = failed_games.count
    failed_games_names = []
    if failed_games.blank?
      respond_to do |format|
        format.html {
          redirect_to games_path,
          notice: "Database was successfully rebuilt. #{variable_returned[0]} games added. No errors."
        }
        format.json { head :no_content }
      end
    else
      respond_to do |format|
        failed_games.each { |failed_game| failed_games_names.push(failed_game.game_name) }
        if @number_of_failed_games < 5
          flash[:flash_failed_games_names] = failed_games_names
        else
          flash[:flash_failed_games_names] = failed_games_names[0..4].push(
            "And #{failed_games_names.count - 5} other games."
          )
        end
        format.html {
          redirect_to games_path(view_param: 'any_errors', failed_param: @number_of_failed_games),
          notice: "Database was rebuilt. #{variable_returned[0]} games added."
        }
        format.json { head :no_content }
      end
    end
  end

  # GET /games/update_db
  def update_db
    @game = Game.order('humble_bundle DESC').first
    if @game.blank?
      variable_returned = PullDatabase.rebuild_database(1)
    else
      variable_returned = PullDatabase.rebuild_database(@game.humble_bundle)
    end
    failed_games = variable_returned[1]
    failed_games_names = []
    @number_of_failed_games = failed_games.count
    if failed_games.blank?
      respond_to do |format|
        format.html {
          redirect_to games_path(view_param: 'any_errors'),
          notice: "#{variable_returned[0]} games were successfully added. No errors."
        }
        format.json { head :no_content }
      end
    else
      respond_to do |format|
        failed_games.each {|failed_game| failed_games_names.push(failed_game.game_name) }
        if @number_of_failed_games < 5
          flash[:flash_failed_games_names] = failed_games_names
        else
          flash[:flash_failed_games_names] = failed_games_names[0..4].push(
            "And #{failed_games_names.count-5} other games."
          )
        end
        format.html {
          redirect_to games_path(view_param: 'any_errors', failed_param: @number_of_failed_games),
          notice: "Database was rebuilt. #{variable_returned[0]} games added."
        }
        format.json { head :no_content }
      end
    end
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
