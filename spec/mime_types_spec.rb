require'spec_helper'

describe 'renderer and mime types' do

  it "is registered" do
    ActionController::Renderers::RENDERERS.include?(:xlsx)
    ActionController::Renderers::RENDERERS.include?(:xls)
    ActionController::Renderers::RENDERERS.include?(:csv)
  end

  it "xlsx mime type" do
    Mime::XLSX.should be
    Mime::XLSX.to_sym.should == :xlsx
    Mime::XLSX.to_s.should == "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
  end

  it "xls mime type" do
    Mime::XLS.should be
    Mime::XLS.to_sym.should == :xls
    Mime::XLS.to_s.should == "application/vnd.ms-excel"
  end

  it "csv mime type" do
    Mime::CSV.should be
    Mime::CSV.to_sym.should == :csv
    Mime::CSV.to_s.should == "text/csv"
  end
end