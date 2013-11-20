unless defined? Mime::XLSX
  Mime::Type.register "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", :xlsx
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
  def to_xlsx
    if options[:stream] == true
      options[:data] ||= {}
      options[:data][:url] ||= controller.request.url.gsub(/xlsx\Z/, "csv")
    end
    controller.render({:xlsx => resources.last }.merge(options))
  end
end
