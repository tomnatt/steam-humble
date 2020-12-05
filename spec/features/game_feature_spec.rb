require 'rails_helper'

RSpec.describe 'Accessing the games pages', type: :feature do
  before :each do
    # User.make(email: 'user@example.com', password: 'password')
  end

  it 'shows me a list of all games' do
    visit '/'
    expect(page).to have_content 'All games'
    expect(page).to have_content 'add a game'
  end
end
