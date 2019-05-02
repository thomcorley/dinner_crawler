# frozen_string_literal: true

RSpec.feature "RecipeMiner" do
  include StubRequestSpecHelper

  let(:grubdaily_webpage) { File.read("spec/test_data/recipe_webpage_full.html") }
  let(:gordon_ramsay_webpage) { File.read("spec/test_data/gordon_ramsay_example_page.html") }
  let(:bbcgoodfood_webpage) { File.read("spec/test_data/bbcgoodfood_webpage.html") }
  let(:crawler) { WebpageCrawler.new("https://www.grubdaily.com/example") }
  before(:each) { Recipe.all.each(&:destroy) }

  it "mines www.grubdaily.com successfully" do
    stub_get_request_with(grubdaily_webpage)
    crawler.crawl

    expect(Recipe.count).to eq(1)
    expect(Ingredient.count).to eq(11)
    expect(Instruction.count).to eq(5)
  end

  it "mines www.gordonramsay.com successfully" do
    stub_get_request_with(gordon_ramsay_webpage)
    crawler.crawl

    expect(Recipe.count).to eq(1)
    expect(Ingredient.count).to eq(11)
  end

  it "mines bbcgoodfood successfully" do
    pending("this is a work in progress")
    stub_get_request_with(bbcgoodfood_webpage)
    WebpageCrawler.new("https://www.bbcgoodfood.com")

    expect(Recipe.count).to eq(1)
    expect(Ingredient.count).to eq(11)
  end
end
