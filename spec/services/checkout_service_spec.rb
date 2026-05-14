require "rails_helper"

RSpec.describe CheckoutService, type: :service do
  let(:user) { create(:user) }
  let(:category) { create(:category) }
  let(:product) { create(:product, category: category) }
  let(:variant) { create(:product_variant, product: product, price: 100.0, stock: 5) }
  let(:address) { create(:address, user: user) }

  before do
    cart = create(:cart, user: user)
    create(:cart_item, cart: cart, product_variant: variant, quantity: 2)
  end

  describe "#call" do
    context "with valid data" do
      it "creates an order" do
        result = described_class.new(user, address.id).call

        expect(result[:success]).to be true
        expect(result[:order]).to be_persisted
        expect(result[:order].status).to eq("pending")
        expect(result[:order].total).to eq(200.0)
      end

      it "creates order items" do
        result = described_class.new(user, address.id).call

        expect(result[:order].order_items.count).to eq(1)
        expect(result[:order].order_items.first.price).to eq(100.0)
        expect(result[:order].order_items.first.quantity).to eq(2)
      end

      it "decrements stock" do
        expect { described_class.new(user, address.id).call }
          .to change { variant.reload.stock }.from(5).to(3)
      end

      it "clears the cart" do
        described_class.new(user, address.id).call

        expect(user.cart.cart_items.reload).to be_empty
      end
    end

    context "with insufficient stock" do
      before do
        variant.update!(stock: 1)
      end

      it "returns an error" do
        result = described_class.new(user, address.id).call

        expect(result[:success]).to be_nil
        expect(result[:error]).to include("Insufficient stock")
      end

      it "does not create an order" do
        expect { described_class.new(user, address.id).call }
          .not_to change(Order, :count)
      end

      it "does not decrement stock" do
        expect { described_class.new(user, address.id).call }
          .not_to change { variant.reload.stock }
      end
    end

    context "with an empty cart" do
      before do
        user.cart.cart_items.destroy_all
      end

      it "returns an error" do
        result = described_class.new(user, address.id).call

        expect(result[:error]).to eq("Cart is empty")
      end
    end
  end
end
