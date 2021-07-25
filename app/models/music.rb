class Music < ApplicationRecord
  belongs_to :user
  validates_presence_of :title, :artist, :release_date, :duration

  def duration
    if not super
      return nil
    end

    return super.strftime("%H:%M:%S")
  end
end
