class Checkout
	attr_reader :subtotal, :total, :items
	def initialize
		@subtotal = 0
		@total		= 0
		@items		= {}
	end

	def scan(item)
		update_items(item)	
		update_subtotal(item)
		update_total(item)	
	end

	def update_items(item)
		if items[item.barcode]
			@items[item.barcode] += 1
		else
			@items[item.barcode] = 1
		end
	end

	def update_total(item)
		if discount_rules[item.barcode] && items[item.barcode].to_i >= discount_rules[item.barcode][:quantity]
			@total = @subtotal - (items[item.barcode] / discount_rules[item.barcode][:quantity]).floor * discount_rules[item.barcode][:amount]
		else
			@total = @subtotal
		end
	end

	def update_subtotal(item)
		@subtotal += item.price
	end

	def quantity(item)
	#puts items
		items[item.barcode]
	end

	def discount_rules
		{ "A" => { quantity: 3, amount: 20 },
			"B" => { quantity: 2, amount: 15 } }
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

		it "if we have 3 of the same item, but discount works for 2, it is applied correctly" do
			checkout = Checkout.new
			checkout.scan(Item.new("A", 50))
			checkout.scan(Item.new("B", 30))
			checkout.scan(Item.new("B", 30))
			checkout.scan(Item.new("B", 30))
			expect(checkout.total).to eq(125)
		end










		
	end
end
