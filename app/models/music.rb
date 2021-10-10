class Music < ApplicationRecord
  belongs_to :user
  validates_presence_of :title, :artist, :release_date, :duration

  def duration
    
    if not super
      return nil
    end

    return super.strftime("%H:%M:%S")
  end

  def created_at
    
    if not super
      return nil
    end

    return super.strftime("%Y-%m-%d %H:%M:%S.%L")
  end

  def updated_at
    
    if not super
      return nil
    end

    return super.strftime("%Y-%m-%d %H:%M:%S.%L")
  end
end
