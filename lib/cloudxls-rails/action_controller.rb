require 'csv'
require 'action_controller'

unless defined? Mime::XLS
  Mime::Type.register "application/vnd.ms-excel", :xls
end

unless defined? Mime::XLSX
  Mime::Type.register "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", :xlsx
end

ActionController::Renderers.add :csv do |scope, options|
  filename = options.fetch(:filename, 'data.csv')
  columns  = options[:columns]

  if options.fetch(:stream, false)
    # streaming response
    headers["Content-Type"] = "text/csv"
    headers["Content-disposition"] = "attachment; filename=\"#{filename}\""
    headers["Cache-Control"] ||= "no-cache"
    headers.delete("Content-Length")
    response.status = 200

    stream = CloudXLS::CSVWriter.enumerator(scope, {:columns => columns})
    self.response_body = stream
  else # no stream:
    data = CloudXLS::CSVWriter.text(scope, {:columns => columns})

    send_data data,
      type: Mime::CSV,
      disposition: "attachment; filename=#{filename}.csv"
  end
end

ActionController::Renderers.add :xls do |scope, options|
  columns  = options.fetch(:columns, nil)

  xdata = options[:data] || {}
  unless (xdata.has_key?(:text) ||
          xdata.has_key?(:url ) ||
          xdata.has_key?(:file)  )

    xdata[:text] = CloudXLS::CSVWriter.text(scope, {:columns => columns})
  end

  xopts = {:data => xdata}
  xopts[:sheet] = options[:sheet] if options[:sheet]
  xopts[:doc]   = options[:doc]   if options[:doc]

  response = CloudXLS.xpipe(xopts)
  redirect_to response.url
end

ActionController::Renderers.add :xlsx do |scope, options|
  columns  = options.fetch(:columns, nil)

  xdata = options[:data] || {}
  unless (xdata.has_key?(:text) ||
          xdata.has_key?(:url ) ||
          xdata.has_key?(:file)  )

    xdata[:text] = CloudXLS::CSVWriter.text(scope, {:columns => columns})
  end

  xopts = {:data => xdata}
  xopts[:sheet] = options[:sheet] if options[:sheet]
  xopts[:doc]   = options[:doc] || {}
  xopts[:doc][:format] = 'xlsx'

  response = CloudXLS.xpipe(xopts)
  redirect_to response.url
end

# For respond_to default
class ActionController::Responder
  def to_csv
    controller.render({:csv => resources.last, :stream => false }.merge(options))
  end

  def to_xls
    if options[:stream] == true
      options[:data] ||= {}
      options[:data][:url] ||= controller.request.url.gsub(/xls\Z/, "csv")
    end
    controller.render({:xls => resources.last  }.merge(options))
  end

  def to_xlsx
    if options[:stream] == true
      options[:data] ||= {}
      options[:data][:url] ||= controller.request.url.gsub(/xlsx\Z/, "csv")
    end
    controller.render({:xlsx => resources.last }.merge(options))
  end
end
