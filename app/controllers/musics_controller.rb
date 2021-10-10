class MusicsController < ApplicationController
  include Paginable

  before_action :set_music, only: [:show, :update, :destroy, :definitive_delete_music]
  before_action :verify_deleted_music, only: [:show, :update, :destroy]
  before_action :verify_music_fields, only: [:create, :update]
  before_action :verify_restore_deleted_musics, only: :restore_deleted_musics
  before_action :verify_not_deleted_music, only: :definitive_delete_music
  
  def index
    @musics = Music.where(deleted: false, user: @current_user).order(artist: :asc, title: :asc).page(page).per(size)
    json_response(paged_musics(@musics))
  end

  def show
    json_response(@music)
  end

  def create
    create_music_params = music_params
    create_music_params[:user] = @current_user
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
    json_response(Music.where(deleted: true, user: @current_user).count)
  end

  def index_deleted_musics
    @musics = Music.where(deleted: true, user: @current_user).order(artist: :asc, title: :asc).page(page).per(size)
    json_response(paged_musics(@musics))
  end

  def restore_deleted_musics
    ids = params[:_json].map { |m| m[:id] }
    result = Music.where(id: ids, deleted: true, user: @current_user)
                  .update_all(deleted: false)
    json_response(result)
  end

  def definitive_delete_music
    @music.destroy
    json_response
  end

  def empty_list
    result = Music.where(deleted: true, user: @current_user).destroy_all
    json_response(result.length)
  end

  private 

  def music_params
    params.permit(:title, :artist, :release_date, :duration, :number_views, :feat)
  end

  def set_music
    @music = Music.find_by(id: params[:id], user: @current_user)
    if not @music
      raise ActiveRecord::RecordNotFound.new(message = nil, model = nil, primary_key = nil, id = nil)
    end
  end

  def verify_deleted_music
    if @music.deleted
      raise ActiveRecord::RecordNotFound.new(message = nil, model = nil, primary_key = nil, id = nil)
    end
  end

  def verify_music_fields

    if music_params[:title].blank?
      raise(ExceptionHandler::FieldError, Messages::TITLE_IS_REQUIRED)
    end

    if music_params[:artist].blank?
      raise(ExceptionHandler::FieldError, Messages::ARTIST_IS_REQUIRED)
    end

    if music_params[:release_date].blank?
      raise(ExceptionHandler::FieldError, Messages::RELEASE_DATE_IS_REQUIRED)
    end

    if music_params[:duration].blank?
      raise(ExceptionHandler::FieldError, Messages::DURATION_IS_REQUIRED)
    end

    if /\d{4}-\d{2}-\d{2}/.match(music_params[:release_date]).nil?
      raise(ExceptionHandler::FieldError, Messages::WRONG_RELEASE_DATE_FORMAT)
    end

    begin

      release_date = Date.strptime(music_params[:release_date], '%Y-%m-%d')
      if release_date > Date.today
        raise(ExceptionHandler::FieldError, Messages::RELEASE_DATE_CANNOT_BE_FUTURE)
      end
    rescue Date::Error
      raise(ExceptionHandler::FieldError, Messages.get_invalid_date(music_params[:release_date]))
    end

    if /\d{2}:\d{2}:\d{2}/.match(music_params[:duration]).nil?
      raise(ExceptionHandler::FieldError, Messages::WRONG_DURATION_FORMAT)
    end

    begin

      Time.strptime(music_params[:duration], '%H:%M:%S')
    rescue ArgumentError
      raise(ExceptionHandler::FieldError, Messages.get_invalid_time(music_params[:duration]))
    end
  end

  def verify_restore_deleted_musics
    params.require(:_json)
    params[:_json].each do |m|
      if not m.has_key?(:id)
        raise(ExceptionHandler::FieldError, Messages::ID_IS_REQUIRED)
      end
    end
  end

  def verify_not_deleted_music
    if not @music.deleted
      raise ActiveRecord::RecordNotFound.new(message = nil, model = nil, primary_key = nil, id = nil)
    end
  end
end
