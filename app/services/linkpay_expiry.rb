# Turns an invoice due date into the moment the payment link has to die:
# the end of the due date in Estonian time (Europe/Tallinn, EET/EEST).
#
#   LinkpayExpiry.new('2026-07-09').iso8601 # => "2026-07-09T20:59:59Z" (summer, UTC+3)
#   LinkpayExpiry.new('2026-12-09').iso8601 # => "2026-12-09T21:59:59Z" (winter, UTC+2)
class LinkpayExpiry
  class InvalidDueDate < StandardError; end

  TIME_ZONE = 'Europe/Tallinn'.freeze
  DATE_PATTERN = /\A\d{4}-\d{2}-\d{2}\z/

  attr_reader :date

  # Strict parser: nil/blank means "no due date", anything that is not a Date
  # or an exact YYYY-MM-DD string is an error - we never silently drop an
  # expiry the caller asked for.
  def self.parse_date(value)
    return nil if value.nil? || value.to_s.strip.empty?
    return value.to_date if value.is_a?(Date) || value.is_a?(Time)

    string = value.to_s.strip
    raise InvalidDueDate, "Invalid due_date '#{string}', expected format YYYY-MM-DD" unless string.match?(DATE_PATTERN)

    begin
      Date.iso8601(string)
    rescue ArgumentError
      raise InvalidDueDate, "Invalid due_date '#{string}', expected format YYYY-MM-DD"
    end
  end

  def initialize(due_date)
    @date = self.class.parse_date(due_date)
  end

  # End of the due date in Estonian time, nil when there is no due date.
  def end_of_day
    return nil if date.nil?

    ActiveSupport::TimeZone[TIME_ZONE].local(date.year, date.month, date.day).end_of_day
  end

  # ISO 8601 UTC representation Montonio expects in `expiresAt`.
  def iso8601
    end_of_day&.utc&.iso8601
  end

  def present?
    !date.nil?
  end
end
