FactoryBot.define do
  factory :game do
    steam_appid { 1 }
    game_name { 'Game name' }
    humble_bundle { '2020-05-01' }
  end
end
