class PostsController < ApplicationController
  respond_to :csv, :xls, :xlsx, :html

  def index
    respond_with(Post.all, :columns => %w[title visits conversion_rate published_on published expired_at])
  end

  # Used for stub/mocking a redirect request
  def successful_redirect
    render :text => "xls"
  end
end
