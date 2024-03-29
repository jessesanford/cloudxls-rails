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

  it "#as_csv" do
    expect( @post.as_csv(except: [:unix_timestamp, :created_at, :updated_at]) ).to eq([@post.id, "hello world", 12_032, 0.24, "2013-12-24", "2013-12-25T12:30:30.000+0000", false])
    expect( @post.as_csv(only: [:title]) ).to eq(["hello world"])
    expect( @post.as_csv(only: [:title, :visits]) ).to eq(["hello world", 12_032])
    expect( @post.as_csv(only: [:expired_at]) ).to eq(["2013-12-25T12:30:30.000+0000"])
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

  it "/posts/all_columns.csv streams csv" do
    visit '/posts/all_columns.csv'
    page.should have_content [
      "Id,Title,Visits,Conversion Rate,Published On,Expired At,Published,Unix Timestamp,Created At,Updated At",
      "1,hello world,12032,0.24,2013-12-24,2013-12-25T12:30:30.000+0000,false,2013-12-25T12:30:30.000+0000,#{@post.created_at.as_csv},#{@post.updated_at.as_csv}"
    ].join("\n")
  end

  it "/posts/stream.csv streams csv" do
    visit '/posts/stream.csv'
    page.should have_content [
      "Title,Visits,Conversion Rate,Published On,Published,Expired At",
      "hello world,12032,0.24,2013-12-24,false,2013-12-25T12:30:30.000+0000"
    ].join("\n")
  end


  describe "posts/stream" do
    it "/posts/stream.csv should xpipe with csv url" do
      visit '/posts/stream.csv'
      page.should have_content [
        "Title,Visits,Conversion Rate,Published On,Published,Expired At",
        "hello world,12032,0.24,2013-12-24,false,2013-12-25T12:30:30.000+0000"
      ].join("\n")
    end

    it "/posts/stream.xlsx has a working csv export" do
      CloudXLS.should_receive(:xpipe) { |options|
        !options[:data][:url].ends_with?("posts/stream.csv") &&
        options[:doc][:format] == "xlsx" &&
        options.keys.length == 2
      }.and_return(OpenStruct.new(:url => "/successful_redirect"))

      visit '/posts/stream.xlsx'
      page.should have_content("OK")
    end

    it "/posts/stream.xls has a working csv export" do
      CloudXLS.should_receive(:xpipe) { |options|
        !options[:data][:url].ends_with?("posts/stream.csv") &&
          options.keys.length == 1
      }.and_return(OpenStruct.new(:url => "/successful_redirect"))

      visit '/posts/stream.xls'
      page.should have_content("OK")
    end
  end

  describe "/posts/stream_with_custom_url" do
    it "/posts/stream_with_custom_url.csv should xpipe with csv url" do
      visit '/posts/stream_with_custom_url.csv'
      page.should have_content [
        "Title,Visits,Conversion Rate,Published On,Published,Expired At",
        "hello world,12032,0.24,2013-12-24,false,2013-12-25T12:30:30.000+0000"
      ].join("\n")
    end

    it "/posts/stream_with_custom_url.xls will redirect to custom url" do
      CloudXLS.should_receive(:xpipe) { |options|
        !options[:data][:url].ends_with?("successful_redirect") &&
          options.keys.length == 1
      }.and_return(OpenStruct.new(:url => "/successful_redirect"))

      visit '/posts/stream_with_custom_url.xls'
      page.should have_content("OK")
    end

    it "/posts/stream_with_custom_url.xlsx will redirect to custom url" do
      CloudXLS.should_receive(:xpipe) { |options|
        !options[:data][:url].ends_with?("successful_redirect") &&
          options.keys.length == 1
      }.and_return(OpenStruct.new(:url => "/successful_redirect"))

      visit '/posts/stream_with_custom_url.xlsx'
      page.should have_content("OK")
    end
  end
end
