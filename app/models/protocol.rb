class Protocol < ActiveRecord::Base
  attr_accessible :name, :introduction
  belongs_to :user
  has_many :authors, :dependent => :delete_all
  has_many :reagents
  has_many :steps, :order => "position asc"
  has_many :comments

  define_index do
    indexes :name
  end

  def introduction=(text)
    write_attribute(:introduction, Sanitize.clean(text, SANITIZE_OPTIONS))
  end

  def total_time_components
    times_hash = self.steps.each_with_object({
      :hours => 0,
      :minutes => 0,
      :seconds => 0
    }) do |step, memo|
      memo[:hours] += step.duration_hours.to_i
      memo[:minutes] += step.duration_minutes.to_i
      memo[:seconds] += step.duration_seconds.to_i
    end
    times_hash[:minutes] += times_hash[:seconds] / 60
    times_hash[:seconds] = times_hash[:seconds] % 60
    times_hash[:hours] += times_hash[:minutes] / 60
    times_hash[:minutes] = times_hash[:minutes] % 60
    [times_hash[:hours], times_hash[:minutes], times_hash[:seconds]]
  end
end