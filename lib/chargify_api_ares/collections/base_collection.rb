class BaseCollection < ActiveResource::Collection
  attr_accessor :total_count, :current_page

  DEFAULT_PER_PAGE = 20.freeze

  def initialize(parsed = {})
    collection_name = self.class.name.downcase.match(/.+?(?=collection)/)[0]

    @total_count = parsed['meta']["total_#{collection_name}_count"]
    @current_page = parsed['meta']['current_page']
  end

  def next_page
    return current_page unless current_page < total_pages

    current_page + 1
  end

  def total_pages
    (total_count.to_f / per_page.to_f).ceil
  end

  def per_page
    original_params[:per_page] || DEFAULT_PER_PAGE
  end
end
