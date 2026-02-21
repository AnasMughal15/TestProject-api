class StandardReportJob < ApplicationJob
  include Trackable

  queue_as :standard

  def perform(report_type)
    Rails.logger.info "[StandardReportJob] Generating report: #{report_type}"
    # Replace with real report generation logic
  end
end
