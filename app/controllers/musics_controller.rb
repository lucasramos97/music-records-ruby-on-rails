class MusicsController < ApplicationController
  before_action :set_music, only: [:show, :update]
  
  def index
    @musics = Music.all
    json_response(@musics)
  end

  def show
    json_response(@music)
  end

  def create
    @music = Music.create!(music_params)
    json_response(@music, :created)
  end

  def update
    @music.update!(music_params)
    json_response(@music)
  end

  private 

  def music_params
    params.permit(:title, :artist, :release_date, :duration, :number_views, :feat)
  end

  def set_music
    @music = Music.find(params[:id])
  end

end
