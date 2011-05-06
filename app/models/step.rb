class Step < ActiveRecord::Base
  attr_accessible :name            ,
                  :instructions    ,
                  :position        ,
                  :duration_hours  ,
                  :duration_minutes,
                  :duration_seconds
  belongs_to :image
  belongs_to :protocol
  validates :position, :numericality => true
  def instructions=(text)
    write_attribute(:instructions, Sanitize.clean(text, SANITIZE_OPTIONS))
  end

  before_save :set_defaults

  private
    def set_defaults
      self.name = "Step #{self.position}" if self.name.blank?
      self.instructions = "Please enter instructions for this step." if self.instructions.blank?
    end
end