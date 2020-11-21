require 'rails_helper'

RSpec.describe 'Games', type: :request do
  it 'creates a Game and redirects to the Game page' do
    get '/games/new'
    expect(response).to render_template(:new)

    post '/games', params: { game: { steam_appid:   928,
                                     game_name:     'Controller spec',
                                     humble_bundle: '2020-05-01' } }

    expect(response).to redirect_to(assigns(:game))
    follow_redirect!

    expect(response).to render_template(:show)
    expect(response.body).to include('Game was successfully created.')
  end

  it 'does not render a different template' do
    get '/games/new'
    expect(response).to_not render_template(:show)
  end
end
