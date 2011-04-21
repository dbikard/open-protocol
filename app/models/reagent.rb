class Reagent < ActiveRecord::Base
  attr_accessible :name, :external_link
  belongs_to :protocol
  validates :name, :presence => true, :length => { :maximum => 255 }

  def external_link=(link)
    if link =~ /^https?:\/\//
      write_attribute(:external_link, link)
    else
      write_attribute(:external_link, "http://#{link}")
    end
  end
end