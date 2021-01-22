require 'pull_databases'

describe PullDatabase do

  describe ".pull_steam_app_db" do
    context "when called" do
      it "returns steam database hash" do
        expect(PullDatabase.pull_steam_app_db).not_to be_empty
      end
    end
  end

  describe ".pull_steam_app_db" do
    context "when called" do
      it "returns a hash of game_name to appid" do
        steam_data = PullDatabase.pull_steam_app_db
        expect(steam_data['HammerHelm']).to eq(664000)
      end
    end
  end

  describe ".steam_id_options_creator" do
    context "when called with no input" do
      it "returns an array with a Leave Blank message and nil" do
        steam_id_options = PullDatabase.steam_id_options_creator('')
        expect(steam_id_options[0][0]).to include('Leave blank')
        expect(steam_id_options[0][1]).to be_nil
      end
    end
  end

  describe ".steam_id_options_creator" do
    context "when called with a game (HammerHelm)" do
      it "returns an array with the name and appid" do
        steam_id_options = PullDatabase.steam_id_options_creator('HammerHelm')
        expect(steam_id_options[0][0]).to include('Leave blank')
        expect(steam_id_options[0][1]).to be_nil
        expect(steam_id_options[1][0]).to include('HammerHelm')
        expect(steam_id_options[1][1]).to eq(664000)
      end
    end
  end
end
