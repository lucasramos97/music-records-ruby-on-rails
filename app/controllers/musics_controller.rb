class MusicsController < ApplicationController
  include Paginable

  before_action :set_music, only: [:show, :update, :destroy]
  before_action :verify_deleted_music, only: [:show, :update, :destroy]
  
  def index
    @musics = Music.where(deleted: false).order(artist: :asc, title: :asc).page(page).per(size)
    json_response(paged_musics(@musics))
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

  def destroy
    @music.update!(deleted: true)
    json_response(@music)
  end

  private 

  def music_params
    params.permit(:title, :artist, :release_date, :duration, :number_views, :feat)
  end

  def set_music
    @music = Music.find(params[:id])
  end

  def verify_deleted_music
    if @music.deleted
      raise ActiveRecord::RecordNotFound.new(message = '', model = @music, primary_key = @music.id, id = @music.id)
    end
  end

end
