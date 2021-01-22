require 'rails_helper'

# rubocop:disable Metrics/BlockLength
RSpec.describe Game, type: :model do
  it 'must have a unique appid' do
    create(:game, steam_appid: 21)
    game = build(:game, steam_appid: 21)
    expect(game).to_not be_valid
  end

  it 'must have an appid which is an integer' do
    game = build(:game, steam_appid: '12aa')
    expect(game).to_not be_valid
  end

  it 'must have a name' do
    game = build(:game, game_name: 'Game 1')
    expect(game).to be_valid

    game = build(:game, game_name: nil)
    expect(game).to_not be_valid
  end

  it 'must have a unique name' do
    create(:game, game_name: 'Game 1')
    game = build(:game, game_name: 'Game 1')
    expect(game).to_not be_valid
  end

  it 'must have a date' do
    game = build(:game, humble_bundle: '2020-05-01')
    expect(game).to be_valid

    game = build(:game, humble_bundle: nil)
    expect(game).to_not be_valid
  end
end
# rubocop:enable Metrics/BlockLength
