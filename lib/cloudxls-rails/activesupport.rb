require 'active_support/time_with_zone'

module ActiveSupport
  class TimeWithZone
    def as_csv(options = nil)
      to_datetime.as_csv
    end
  end
end
