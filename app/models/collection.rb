class Collection < ActiveRecord::Base
  attr_accessible(:name, :contact, :homepage, :description)
  belongs_to :user
  has_many :categories
  has_many :collection_admins, :dependent => :destroy

  has_many :admins, :through => :collection_admins

  after_create :make_owner_admin

  define_index do
    indexes :name
  end

  def add_new_admin!(user)
    collection_admin = self.collection_admins.build
    collection_admin.admin = user
    collection_admin.save!
  end

  def add_emails_as_admins!(admin_emails)
    admins = User.where(:email => admin_emails)
    # TODO: Email invitations to admins who are not yet users.
    admins.each {|admin| add_new_admin!(admin) }
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
      self.add_new_admin!(self.user)
    end
end