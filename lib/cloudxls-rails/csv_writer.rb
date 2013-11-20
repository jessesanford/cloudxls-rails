require 'csv'

module CloudXLS
  class CSVWriter
    DATETIME_FORMAT = "%FT%T.%L%z".freeze
    DATE_FORMAT = "%F".freeze

    # Generates CSV string.
    #
    # @param [Array<String/Symbol>] columns
    #   Method/attribute keys to for the export.
    #
    # @return [String]
    #   The full CSV as a string. Titleizes *columns* for the header.
    #
    def self.text(scope, options = {})
      columns = options[:columns]

      str = ::CSV.generate do |csv|

        if options[:skip_headers] != true
          if scope.respond_to?(:column_names)
            columns ||= scope.column_names
          end
          if columns
            csv << csv_titles(columns, :titleize)
          end
        end

        enum = scope_enumerator(scope)
        scope.send(enum) do |record|
          csv << csv_row(record, columns)
        end
      end
      str.strip!
    end

    # Example
    #
    #     Post.csv_enumerator(Post.all, [:title, :author, :published_at])
    #
    # @param [ActiveRecord::Scope] scope
    #   An activerecord scope object for the records to be exported.
    #   Example: Post.all.limit(500).where(author: "foo")
    #
    # @return [Enumerator] enumerator to use for streaming response.
    #
    def self.enumerator(scope, options = {})
      columns = options[:columns]

      Enumerator.new do |row|
        if options[:skip_headers] != true
          if scope.respond_to?(:column_names)
            columns ||= scope.column_names
          end
          if columns
            row << csv_titles(columns, :titleize).to_csv
          end
        end

        enum = scope_enumerator(scope)
        scope.send(enum) do |record|
          row << csv_row(record, columns).to_csv
        end
      end
    end

  private


    def self.csv_row(obj, columns = [])
      if obj.is_a?(Array)
        obj.map{ |el| encode_for_csv(el) }
      else
        columns.map do |key|
          encode_for_csv(obj.send(key))
        end
      end
    end


    def self.encode_for_csv(val)
      case val
      when DateTime,Time then val.strftime(DATETIME_FORMAT)
      when Date          then val.strftime(DATE_FORMAT)
      else
        val
      end
    end

    def self.csv_titles(column_names, strategy = :titleize)
      column_names.map do |c|
        title = c.to_s
        title = title.send(strategy) if title.respond_to?(strategy)
        title
      end
    end


    def self.scope_enumerator(scope)
      if scope.respond_to?(:find_each)
        :find_each
      else
        :each
      end
    end
  end
end