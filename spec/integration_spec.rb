require 'ostruct'
require 'spec_helper'

describe 'Request', :type => :request do
  before :each do
    Post.delete_all
    @post = Post.create(
      :title => "hello world",
      :visits => 12_032,
      :conversion_rate => 0.24,
      :published_on   => Date.new(2013,12,24),
      :expired_at     => DateTime.new(2013,12,25,12,30,30),
      :unix_timestamp => DateTime.new(2013,12,25,12,30,30),
      :published => false)
  end

  it "has a working test_app" do
    visit '/'
    page.should have_content "Users"
  end

  it "/posts.csv has a working csv export" do
    visit '/posts.csv'
    page.should have_content [
      "Title,Visits,Conversion Rate,Published On,Published,Expired At",
      "hello world,12032,0.24,2013-12-24,false,2013-12-25T12:30:30.000+0000"
    ].join("\n")
  end

  it "/posts.xls has a working csv export" do
    CloudXLS.should_receive(:xpipe).and_return(OpenStruct.new(:url => "/successful_redirect"))
    visit '/posts.xls'
  end
end
