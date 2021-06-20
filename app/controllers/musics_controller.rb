class MusicsController < ApplicationController
  before_action :set_music, only: [:show]
  
  def index
    @musics = Music.all
    json_response(@musics)
  end

  def show
    json_response(@music)
  end

  private 

  def music_params
    params.permit(:title, :artist, :release_date, :duration)
  end

  def set_music
    @music = Music.find(params[:id])
  end

end
