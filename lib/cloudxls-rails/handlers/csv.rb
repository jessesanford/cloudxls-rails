# CloudXLSRails::CSVResponder
module CloudXLSRails
  class CSVResponder
    def initialize(controller, stream)
      @controller = controller
      @stream = stream
    end

    def stream!(filename)
      headers = @controller.headers
      headers['Last-Modified'] = Time.now.to_s
      headers["Content-Type"] = "text/csv"
      headers["Content-disposition"] = "attachment; filename=\"#{filename}\""
      # nginx doc: Setting this to "no" will allow unbuffered responses suitable
      # for Comet and HTTP streaming applications
      headers['X-Accel-Buffering'] = 'no'
      headers["Cache-Control"] ||= "no-cache"
      headers.delete("Content-Length")

      @controller.response.status = 200
      # setting the body to an enumerator, rails will iterate this enumerator
      @controller.response_body = @stream
    end

    def self.stream!(controller, scope, options)
      filename = options.fetch(:doc, {}).fetch(:filename, "data.csv")
      enum     = CloudXLS::CSVWriter.enumerator(scope, options)
      new(controller, enum).stream!(filename)
    end
  end
end


ActionController::Renderers.add :csv do |scope, options|
  filename = options.fetch(:filename, "data-#{DateTime.now.to_s}.csv")
  columns  = options[:columns]

  if options[:stream] == true
    CloudXLSRails::CSVResponder.stream!(self, scope, options)
  else # no stream:
    data = CloudXLS::CSVWriter.text(scope, {:columns => columns})

    send_data data,
      type: Mime::CSV,
      disposition: "attachment; filename=#{filename}.csv"
  end
end

class ActionController::Responder
  def to_csv
    if options[:stream] == true
      CloudXLSRails::CSVResponder.stream!(controller, resources.last, options)
    else
      controller.render({:csv => resources.last, :stream => false }.merge(options))
    end
  end
end