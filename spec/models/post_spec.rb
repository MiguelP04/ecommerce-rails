require 'rails_helper'

RSpec.describe Post, type: :model do
  describe "broadcasting" do
    it "broadcasts when status changes to published" do
      post = create(:post, status: "draft")
      expect { post.update(status: "published") }.to have_broadcasted_to("notifications_global")
    end
  end
end