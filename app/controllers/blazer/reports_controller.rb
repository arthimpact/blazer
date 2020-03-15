module Blazer
  class ReportsController < BaseController
    before_action :set_report, only: [:edit, :update, :destroy, :run]

    def index
      @reports = Blazer::Report.joins(:query).includes(:query).order("blazer_queries.name, blazer_reports.id").to_a
      @reports.select! { |c| "#{c.query.name} #{c.emails}".downcase.include?(params[:q]) } if params[:q]
    end

    def new
      @report = Blazer::Report.new(query_id: params[:query_id])
    end

    def create
      @report = Blazer::Report.new(report_params)
      # use creator_id instead of creator
      # since we setup association without reporting if column exists
      @report.creator = blazer_user if @report.respond_to?(:creator_id=) && blazer_user

      if @report.save
        redirect_to query_path(@report.query)
      else
        render_errors @report
      end
    end

    def update
      if @report.update(report_params)
        redirect_to query_path(@report.query)
      else
        render_errors @report
      end
    end

    def destroy
      @report.destroy
      redirect_to reports_path
    end

    def run
      @query = @report.query
      redirect_to query_path(@query)
    end

    private

      def report_params
        params.require(:report).permit(:query_id, :emails, :schedule, :subject, :body)
      end

      def set_report
        @report = Blazer::Report.find(params[:id])
      end
  end
end
