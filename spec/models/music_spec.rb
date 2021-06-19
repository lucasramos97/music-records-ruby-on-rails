require 'rails_helper'

RSpec.describe Music, type: :model do
  it { should validate_presence_of(:title) }
  it { should validate_presence_of(:artist) }
  it { should validate_presence_of(:release_date) }
  it { should validate_presence_of(:duration) }
end