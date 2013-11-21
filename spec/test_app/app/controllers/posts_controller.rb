class PostsController < ApplicationController
  respond_to :csv, :xls, :xlsx, :html

  def index
    respond_with(Post.all,
      :columns => export_attributes)
  end

  def stream
    respond_with(Post.all,
      :stream => true,
      :columns => export_attributes)
  end

  def stream_with_custom_url
    respond_with(Post.all,
      :stream => "/successful_redirect",
      :columns => export_attributes)
  end

  # Used for stub/mocking a redirect request
  def successful_redirect
    # make rails 3.1 happy with a template
    # /views/posts/successful_redirect.html.erb
    render :text => "OK"
  end

protected
  def export_attributes
    %w[title visits conversion_rate published_on published expired_at]
  end

end
