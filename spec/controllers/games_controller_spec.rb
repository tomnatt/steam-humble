require 'rails_helper'

# rubocop:disable Metrics/BlockLength
RSpec.describe GamesController, type: :controller do
  describe 'GET index' do
    it 'renders the index template' do
      get :index
      expect(response).to render_template('index')
    end
  end

  describe 'POST create /games' do
    context 'with valid attributes' do
      it 'creates a new game' do
        expect {
          post :create, params: { game: FactoryBot.attributes_for(:game) }
        }.to change(Game, :count).by(1)
      end

      it 'redirects to the new game' do
        post :create, params: { game: FactoryBot.attributes_for(:game) }
        expect(response).to redirect_to(Game.last)
      end
    end

    context 'with invalid attributes' do
      it 'does not create a new game' do
        expect {
          post :create, params: { game: FactoryBot.attributes_for(:game, humble_bundle: nil) }
        }.to_not change(Game, :count)
      end

      it 're-render the new game template' do
        post :create, params: { game: FactoryBot.attributes_for(:game, humble_bundle: nil) }
        expect(response).to render_template :new
      end
    end
  end

  describe 'PATCH update /games' do
    context 'with valid attributes' do
      it 'updates a game' do
        post :create, params: { game: FactoryBot.attributes_for(:game) }
        @game = Game.last
        new_attr = { game_name: 'Game 1', steam_appid: '1', humble_bundle: '2020-05-01', steam_appid_list: '' }
        patch :update, params: { id: @game.id, game: new_attr }
        expect(Game.last.updated_at).to_not eql(Game.last.created_at)
      end

      it 'redirects to the updated game' do
        post :create, params: { game: FactoryBot.attributes_for(:game) }
        @game = Game.last
        new_attr = { game_name: 'Game 1', steam_appid: '1', humble_bundle: '2020-05-01', steam_appid_list: '' }
        patch :update, params: { id: @game.id, game: new_attr }
        expect(response).to redirect_to(Game.last)
      end
    end

    context 'with invalid attributes' do
      it 'does not update a game' do
        post :create, params: { game: FactoryBot.attributes_for(:game) }
        @game = Game.last
        new_attr = { game_name: 'Game 1', steam_appid: '1', humble_bundle: nil, steam_appid_list: '' }
        patch :update, params: { id: @game.id, game: new_attr }
        expect(Game.last.updated_at).to eql(Game.last.created_at)
      end

      it 're-render the edit game template' do
        post :create, params: { game: FactoryBot.attributes_for(:game) }
        @game = Game.last
        new_attr = { game_name: 'Game 1', steam_appid: '1', humble_bundle: nil, steam_appid_list: '' }
        patch :update, params: { id: @game.id, game: new_attr }
        expect(response).to render_template :edit
      end
    end
  end

  describe 'DELETE destroy /games' do
    context 'with valid attributes' do
      it 'deletes a game' do
        post :create, params: { game: FactoryBot.attributes_for(:game) }
        @game = Game.last
        expect {
          delete :destroy, params: { id: @game.id }
        }.to change(Game, :count).by(-1)
      end

      it 'redirects to index' do
        post :create, params: { game: FactoryBot.attributes_for(:game) }
        @game = Game.last
        delete :destroy, params: { id: @game.id }
        expect(response).to redirect_to(games_url)
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
