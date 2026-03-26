class Post < ApplicationRecord
    has_rich_text :content
    has_one_attached :cover_image

    has_many :postables, dependent: :destroy
    has_many :products, through: :postables, source: :postable, source_type: "Product"
    has_many :categories, through: :postables, source: :postable, source_type: "Category"

    enum :status, { draft: 0, published: 1 }

    validates :title, presence: true

    after_save_commit :broadcast_if_published

    private

    def broadcast_if_published
        return unless saved_change_to_status?(to: "published")

        ActionCable.server.broadcast("notification_global", {
            title: title,
            link: Rails.application.routes.url_helpers.post_path(self)
        })
    end
end
