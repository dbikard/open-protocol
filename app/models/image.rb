class Image < ActiveRecord::Base
  belongs_to :user
  attr_accessible(:image)
  has_attached_file :image,
    :styles         => { :thumb => ["120x120#", :png] },
    :storage        => :s3,
    :s3_credentials => Rails.root.join("config", "s3.yml").to_s,
    :path           => "/:style/:id/:filename"

  def thumbnail_url
    self.image.url(:thumb)
  end
  def source_url
    self.image.url
  end
end