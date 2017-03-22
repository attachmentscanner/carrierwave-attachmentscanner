module Fixtures
  def open_fixture(filename)
    File.open(File.expand_path("../../fixtures/#{filename}", __FILE__))
  end
end
