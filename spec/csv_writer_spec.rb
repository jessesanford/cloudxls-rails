require 'spec_helper'

describe "CloudXLS::CSVWriter" do
  before do
    @writer = CloudXLS::CSVWriter
  end

  describe "with array" do
    # spec'ed in cloudlxs-ruby gem
  end

  describe "#text with AR" do
    before do
      Post.delete_all
      @post = Post.create(
        :title           => "hello world",
        :visits          => 12_032,
        :conversion_rate => 0.24,
        :published_on    => Date.new(2013,12,24),
        :expired_at      => DateTime.new(2013,12,25,12,30,30),
        :unix_timestamp  => DateTime.new(2013,12,25,12,30,30),
        :published       => false)
    end

    it "given no records should just return titles" do
      Post.delete_all
      expect( @writer.text(Post.all, :columns => [:title, :visits]) ).to eq("Title,Visits")
    end

    it "should work with a Post.all" do
      expect( @writer.text(Post.all, :columns => [:title, :visits]) ).to eq("Title,Visits\nhello world,12032")
    end

    it "should work with a Post.limit" do
      expect( @writer.text(Post.limit(10), :columns => [:title, :visits]) ).to eq("Title,Visits\nhello world,12032")
    end

    it "should work with a Post.all.to_a" do
      expect( @writer.text(Post.all.to_a, :columns => [:title, :visits]) ).to eq("Title,Visits\nhello world,12032")
    end

    it "should write xmlschema for DateTime" do
      expect( @writer.text(Post.all, :columns => [:expired_at]) ).to eq("Expired At\n2013-12-25T12:30:30.000+0000")
    end

    it "should write YYYY-MM-DD for Date" do
      expect( @writer.text(Post.all, :columns => [:published_on]) ).to eq("Published On\n2013-12-24")
    end
  end
end