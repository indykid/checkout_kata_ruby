class Checkout
	attr_reader :subtotal
	def initialize
		@subtotal = 0
	end

	def scan(item)
		@subtotal += item.price
	end
end

class Item
	attr_reader :price
	def initialize(barcode, price)
		@barcode = barcode
		@price 	 = price
	end
end

describe Checkout do

	describe "#scan" do
		it "adds item to the subtotal" do
			checkout = Checkout.new
			item = Item.new("A", 50)
			checkout.scan(item)
			expect(checkout.subtotal).to eq(50)
		end

		it "keeps adding items to the subtotal" do
			checkout = Checkout.new
			checkout.scan(Item.new("A", 50))
			checkout.scan(Item.new("B", 30))
			expect(checkout.subtotal).to eq(80)
		end

	end
end
