unless defined? Mime::XLS
  Mime::Type.register "application/vnd.ms-excel", :xls
end

# CloudXLSRails::XLSResponder
module CloudXLSRails
  class XLSResponder
    def self.redirect!(controller, scope, options)
      xdata = options[:data] || {}
      unless (xdata.has_key?(:text) ||
              xdata.has_key?(:url ) ||
              xdata.has_key?(:file)  )

        xdata[:text] = CloudXLS::CSVWriter.text(scope, options)
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
    stream = options.delete(:stream) || false
    if stream # either string or boolean
      options[:data] ||= {}
      options[:data][:url] ||= cloudxls_stream_url(stream, 'xls')
    end
    CloudXLSRails::XLSResponder.redirect!(controller, resources.last, options)
  end

protected
  def cloudxls_stream_url(stream, extension = 'xls')
    if stream == true
      controller.request.url.gsub(/#{extension}\Z/, "csv")
    else
      stream.to_s
    end
  end
end
