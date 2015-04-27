class Checkout
  attr_reader :subtotal, :total, :tally
  def initialize
    @subtotal = 0
    @total		= 0
    @tally		= {}
  end

  def scan(item)
    update_tally(item)	
    update_subtotal(item)
    update_total(item)	
  end

  private
  def update_tally(item)
    if tally[item.barcode]
      @tally[item.barcode] += 1
    else
      @tally[item.barcode] = 1
    end
  end

  def update_subtotal(item)
    @subtotal += item.price
  end

  def update_total(item)
    discount = tally.each_key.reduce(0) do |sum, k|
      discount_applicable?(k) ? sum += calculate_discount(k) : sum
    end
    @total = subtotal - discount
  end

  def discount_applicable?(barcode)
    discount_exists?(barcode) && item_quantity(barcode) >= discount_quantity(barcode)
  end

  def calculate_discount(barcode)
    (item_quantity(barcode) / discount_quantity(barcode)).floor * discount_amount(barcode)
  end

  def item_quantity(barcode)
    tally[barcode].to_i
  end

  def discount_exists?(barcode)
    discount_rules[barcode]
  end

  def discount_quantity(barcode)
    discount_rules[barcode][:quantity]
  end

  def discount_amount(barcode)
    discount_rules[barcode][:amount]
  end

  def quantity(item)
    #puts tally
    tally[item.barcode]
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

    it "if item has a discount it is applied to the total" do
      checkout = Checkout.new
      checkout.scan(Item.new("B", 30))
      checkout.scan(Item.new("A", 50))
      checkout.scan(Item.new("A", 50))
      checkout.scan(Item.new("A", 50))
      expect(checkout.total).to eq(160)
    end

    it "if we have 3 of the same item, but discount works for 2, it is applied correctly" do
      checkout = Checkout.new
      checkout.scan(Item.new("A", 50))
      checkout.scan(Item.new("B", 30))
      checkout.scan(Item.new("B", 30))
      checkout.scan(Item.new("B", 30))
      expect(checkout.total).to eq(125)
    end

    it "if we have 4 of the same item, and discount works for 2, discount is applied twice" do
      checkout = Checkout.new
      checkout.scan(Item.new("B", 30))
      checkout.scan(Item.new("B", 30))
      checkout.scan(Item.new("B", 30))
      checkout.scan(Item.new("B", 30))
      expect(checkout.total).to eq(90)
    end

    it "if we have more than one set of items where discounts are applicable, all discounts are applied" do
      checkout = Checkout.new
      checkout.scan(Item.new("B", 30))
      checkout.scan(Item.new("B", 30))
      checkout.scan(Item.new("A", 50))
      checkout.scan(Item.new("A", 50))
      checkout.scan(Item.new("A", 50))
      expect(checkout.total).to eq(175)
    end
  end
end
