class Collection < ActiveRecord::Base
  attr_accessible(:name, :contact, :homepage, :description)
  belongs_to :user
  has_many :categories
  has_many :collection_admins, :dependent => :destroy

  after_create :make_owner_admin

  define_index do
    indexes :name
  end

  def description=(text)
    write_attribute(:description, Sanitize.clean(text, SANITIZE_OPTIONS))
  end
  def homepage=(link)
    if link =~ /^https?:\/\//
      write_attribute(:homepage, link)
    else
      write_attribute(:homepage, "http://#{link}")
    end
  end

  private

    def make_owner_admin
      self_admin = self.collection_admins.build
      self_admin.user = self.user
      self_admin.save!
    end
end