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

  if options.fetch(:stream, false) == true
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

  data     = CloudXLS::CSVWriter.text(scope, {:columns => columns})
  response = CloudXLS.xpipe(data:  { text: data })

  redirect_to response.url
end

ActionController::Renderers.add :xlsx do |scope, options|
  columns  = options.fetch(:columns, nil)

  data     = CloudXLS::CSVWriter.text(scope, {:columns => columns})
  response = CloudXLS.xpipe(:data => {:text => data }, doc: {:format => "xlsx"})

  redirect_to response.url
end

# For respond_to default
class ActionController::Responder
  def to_csv
    controller.render({:csv => resources.last, :stream => false }.merge(options))
  end

  def to_xls
    controller.render({:xls => resources.last, :stream => false }.merge(options))
  end

  def to_xlsx
    controller.render({:xlsx => resources.last, :stream => false}.merge(options))
  end
end
