require 'spec_helper'

describe "Spree::Stock::ContentItem quantity method" do
  context "when called" do
    let(:inventory_unit) { create(:inventory_unit,quantity:4)}
    let(:package) do
      build(
        :stock_package,
        contents: [
          Spree::Stock::ContentItem.new(inventory_unit)
        ]
      )
    end
    it "counts quantity of inventory units" do
      content_item = package.contents.first
      expect(content_item.quantity).to eq 4
    end
  end
end
