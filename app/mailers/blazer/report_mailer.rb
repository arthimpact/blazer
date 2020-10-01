module Blazer
  class ReportMailer < ActionMailer::Base
    include ActionView::Helpers::TextHelper

    default from: Blazer.from_email if Blazer.from_email
    layout false

    def send_report(report, rows_count, error, columns, rows, column_types)
      @report = report
      @rows_count = rows_count
      @error = error
      @columns = columns
      @rows = rows
      @column_types = column_types
      attachment_name = "Report_#{report.query.name}_#{Time.zone.now.strftime("%Y/%b/%d-%I:%M%p")}.csv".gsub(/\s+/, '_')
      csv_file = CSV.generate do |csv|
        csv << columns
        rows.each {|row| csv << row}
      end
      attachments[attachment_name] = csv_file
      subject = report.subject.presence || "Report #{report.query.name}"
      mail to: report.emails, reply_to: report.emails, subject: subject
    end
  end
end
