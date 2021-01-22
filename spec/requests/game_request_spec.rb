require 'rails_helper'

RSpec.describe 'Games', type: :request do
  describe 'GET /games' do
    it "includes the game" do
      game = create(:game, game_name: 'Game 1')
      get games_path
      expect(body).to include('Game 1')
    end
  end
end
