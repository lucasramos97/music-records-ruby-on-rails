module Paginable
  protected

  def page
    (params[:page] || 1).to_i
  end

  def size
    (params[:size] || 5).to_i
  end

  def paged_musics(collection)
    {
      content: collection,
      total: collection.total_count
    }
  end
end