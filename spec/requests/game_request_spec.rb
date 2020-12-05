require 'rails_helper'

RSpec.describe 'Games', type: :request do
  it 'returns a successful response for the index page' do
    get games_path
    expect(response).to be_successful

    # TODO: refactor these to a Capybara test
    expect(response.body).to include('All games')
    expect(response.body).to include('add a game')
  end

  it 'responds properly to a form request' do
    get new_game_path
    expect(response).to be_successful
  end
end
