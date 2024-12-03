class Attachment < ApplicationRecord
  belongs_to :bug

  has_one_attached :image

  validate :validate_image

  private

  def validate_image
    return unless image.attached?

    allowed_types = %w[image/png image/gif]
    unless allowed_types.include?(image.content_type)
      errors.add(:image, "must be a PNG or GIF")
    end

    if image.byte_size > 5.megabytes
      errors.add(:image, "size must be less than 5MB")
    end
  end
end
