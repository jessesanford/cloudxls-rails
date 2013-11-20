unless defined? Mime::XLS
  Mime::Type.register "application/vnd.ms-excel", :xls
end

# CloudXLSRails::XLSResponder
module CloudXLSRails
  class XLSResponder
    def self.redirect!(controller, scope, options)
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
      controller.redirect_to response.url
    end
  end
end


# For respond_to default
class ActionController::Responder
  def to_xls
    if options[:stream] == true
      options[:data] ||= {}
      options[:data][:url] ||= controller.request.url.gsub(/xls\Z/, "csv")
    end
    CloudXLSRails::XLSResponder.redirect!(controller, resources.last, options)
  end
end
