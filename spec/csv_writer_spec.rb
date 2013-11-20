require 'spec_helper'

describe "CloudXLS::CSVWriter" do
  before do
    @writer = CloudXLS::CSVWriter
  end

  describe "with array" do
    it "should not titleize" do
      expect( @writer.text([['foo','bar'],[1,2]]) ).to eq("foo,bar\n1,2")
    end

    it "should escape titles" do
      expect( @writer.text([['bar"baz']]) ).to eq("\"bar\"\"baz\"")
    end

    it "should escape rows" do
      expect( @writer.text([['title'],['bar"baz']]) ).to eq("title\n\"bar\"\"baz\"")
    end

    it "should write YYYY-MM-DD for Date" do
      expect( @writer.text([[Date.new(2012,12,24)]]) ).to eq("2012-12-24")
    end

    it "should write xmlschema for DateTime" do
      # TODO: make UTC consistent
      expect( @writer.text([[DateTime.new(2012,12,24,18,30,5,'+0000')]])             ).to eq("2012-12-24T18:30:05.000+0000")
      expect( @writer.text([[DateTime.new(2012,12,24,18,30,5,'+0000').to_time.utc]]) ).to eq("2012-12-24T18:30:05.000+0000")
    end

    it "should write nothing for nil" do
      expect( @writer.text([[nil,nil]]) ).to eq(",")
    end

    it "should write \"\" for empty string" do
      expect( @writer.text([["",""]]) ).to eq('"",""')
    end

    it "should write integers" do
      expect( @writer.text([[-1,0,1,1_000_000]]) ).to eq('-1,0,1,1000000')
    end

    it "should write floats" do
      expect( @writer.text([[-1.0,0.0,1.0,1_000_000.0,1.234567]]) ).to eq('-1.0,0.0,1.0,1000000.0,1.234567')
    end
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