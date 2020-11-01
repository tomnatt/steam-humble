require 'rails_helper'

RSpec.describe Game, type: :model do
  it 'must have an appid' do
    game = Game.new(steam_appid: 11, game_name: 'Game 1', humble_bundle: '2020-05-01')
    expect(game).to be_valid

    game = Game.new(game_name: 'Game 2', humble_bundle: '2020-05-01')
    expect(game).to_not be_valid
  end

  it 'must have a unique appid' do
    game = Game.new(steam_appid: 21, game_name: 'Game 1', humble_bundle: '2020-05-01')
    game.save!

    game = Game.new(steam_appid: 21, game_name: 'Game 2', humble_bundle: '2020-05-01')
    expect(game).to_not be_valid
  end

  it 'must have an appid which is an integer' do
    game = Game.new(steam_appid: '12aa', game_name: 'Game 1', humble_bundle: '2020-05-01')
    expect(game).to_not be_valid
  end

  it 'must have a name' do
    game = Game.new(steam_appid: 31, game_name: 'Game 1', humble_bundle: '2020-05-01')
    expect(game).to be_valid

    game = Game.new(steam_appid: 32, humble_bundle: '2020-05-01')
    expect(game).to_not be_valid
  end

  it 'must have a date' do
    game = Game.new(steam_appid: 41, game_name: 'Game 1', humble_bundle: '2020-05-01')
    expect(game).to be_valid

    game = Game.new(steam_appid: 42, game_name: 'Game 1')
    expect(game).to_not be_valid
  end
end
