class User < ActiveRecord::Base
  attr_accessible :name, :email, :password, :password_confirmation
  has_many :protocols
  has_many :collections
  has_many :images
  acts_as_authentic do |c|
    c.crypto_provider = Authlogic::CryptoProviders::BCrypt
  end
  has_many :collection_admins
  has_many :administrated_collections, :through => :collection_admins

  after_create :make_default_collection

  def refresh_reset_token!
    self.reset_token = Authlogic::Random.friendly_token
    self.save!
  end

  private

    def make_default_collection
      self.collections.create!(:name => "#{self.name}'s Collections", :contact => self.email)
    end
end
