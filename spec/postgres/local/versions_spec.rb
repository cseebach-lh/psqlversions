RSpec.describe Postgres::Local::Versions do
  it "has a version number" do
    expect(Postgres::Local::Versions::VERSION).not_to be nil
  end

  it "does something useful" do
    expect(false).to eq(true)
  end
end
