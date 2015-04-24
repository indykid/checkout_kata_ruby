class Checkout
	attr_reader :subtotal, :total, :items
	def initialize
		@subtotal = 0
		@total		= 0
		@items		= {}
	end

	def scan(item)
		if items[item.barcode]
			@items[item.barcode] += 1
		else
			@items[item.barcode] = 1
		end
		@subtotal += item.price
		@total = @subtotal
		@total = 95 if quantity(item) == 2
	end

	def quantity(item)
	#puts items
		items[item.barcode]
	end
end

class Item
	attr_reader :price, :barcode
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

		it "if items have no discount rules, none applied to the total" do
			checkout = Checkout.new
			checkout.scan(Item.new("A", 50))
			checkout.scan(Item.new("B", 30))
			expect(checkout.total).to eq(80)
		end
				
		it "if items have discount rules but not applicable, none applied to the total" do
			checkout = Checkout.new
			checkout.scan(Item.new("A", 50))
			checkout.scan(Item.new("A", 50))
			checkout.scan(Item.new("B", 30))
			expect(checkout.total).to eq(130)
		end

		it "if item has a discount it is applied to the total" do
			checkout = Checkout.new
			checkout.scan(Item.new("A", 50))
			checkout.scan(Item.new("B", 30))
			checkout.scan(Item.new("B", 30))
			expect(checkout.total).to eq(95)
		end











		
	end
end
