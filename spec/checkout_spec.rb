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
		it "adds item to the bill" do
			checkout = Checkout.new
			item = Item.new("A", 50)
			checkout.scan(item)
			expect(checkout.subtotal).to eq(50)
		end

	end
end
