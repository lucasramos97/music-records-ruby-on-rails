class MusicsController < ApplicationController
  include Paginable

  before_action :set_music, only: [:show, :update, :destroy, :definitive_delete_music]
  before_action :verify_deleted_music, only: [:show, :update, :destroy]
  before_action :verify_not_deleted_music, only: :definitive_delete_music
  before_action :verify_restore_deleted_musics, only: :restore_deleted_musics
  
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

  def count_deleted_musics
    json_response(Music.where(deleted: true).count)
  end

  def index_deleted_musics
    @musics = Music.where(deleted: true).order(artist: :asc, title: :asc).page(page).per(size)
    json_response(paged_musics(@musics))
  end

  def restore_deleted_musics
    ids = params[:_json].map { |m| m[:id] }
    json_response(Music.where(id: ids).update_all(deleted: false))
  end

  def empty_list
    Music.where(deleted: true).destroy_all
    json_response
  end

  def definitive_delete_music
    @music.destroy
    json_response
  end

  private 

  def music_params
    params.permit(:title, :artist, :release_date, :duration, :number_views, :feat, :user_id)
  end

  def set_music
    @music = Music.find(params[:id])
  end

  def verify_deleted_music
    if @music.deleted
      raise ActiveRecord::RecordNotFound.new(message = '', model = @music, primary_key = @music.id, id = @music.id)
    end
  end

  def verify_restore_deleted_musics
    params.require(:_json)
    params[:_json].each do |m|
      if not m.has_key?(:id)
        raise ActionController::ParameterMissing.new(:id)
      end
    end
  end

  def verify_not_deleted_music
    if not @music.deleted
      raise ActiveRecord::RecordNotFound.new(message = '', model = @music, primary_key = @music.id, id = @music.id)
    end
  end

end
