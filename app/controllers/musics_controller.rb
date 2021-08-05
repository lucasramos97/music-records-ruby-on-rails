class MusicsController < ApplicationController
  include Paginable

  before_action :set_music, only: [:show, :update, :destroy, :definitive_delete_music]
  before_action :verify_deleted_music, only: [:show, :update, :destroy]
  before_action :verify_not_deleted_music, only: :definitive_delete_music
  before_action :verify_restore_deleted_musics, only: :restore_deleted_musics
  
  def index
    @musics = Music.where(deleted: false, user_id: @current_user[:id]).order(artist: :asc, title: :asc).page(page).per(size)
    json_response(paged_musics(@musics))
  end

  def show
    json_response(@music)
  end

  def create
    create_music_params = music_params
    create_music_params[:user_id] = @current_user[:id]
    @music = Music.create!(create_music_params)
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
    json_response(Music.where(deleted: true, user_id: @current_user[:id]).count)
  end

  def index_deleted_musics
    @musics = Music.where(deleted: true, user_id: @current_user[:id]).order(artist: :asc, title: :asc).page(page).per(size)
    json_response(paged_musics(@musics))
  end

  def restore_deleted_musics
    ids = params[:_json].map { |m| m[:id] }
    json_response(Music.where(id: ids, user_id: @current_user[:id]).update_all(deleted: false))
  end

  def empty_list
    Music.where(deleted: true, user_id: @current_user[:id]).destroy_all
    json_response
  end

  def definitive_delete_music
    @music.destroy
    json_response
  end

  private 

  def music_params
    params.except(:music).permit(:title, :artist, :release_date, :duration, :number_views, :feat, :user_id)
  end

  def set_music
    @music = Music.where(id: params[:id], user_id: @current_user[:id]).first
    if not @music
      raise ActiveRecord::RecordNotFound.new(message = nil, model = nil, primary_key = nil, id = nil)
    end
  end

  def verify_deleted_music
    if @music.deleted
      raise ActiveRecord::RecordNotFound.new(message = nil, model = nil, primary_key = nil, id = nil)
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
      raise ActiveRecord::RecordNotFound.new(message = nil, model = nil, primary_key = nil, id = nil)
    end
  end

end
