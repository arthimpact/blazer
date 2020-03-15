module Blazer
  class Report < Record
    belongs_to :creator, optional: true, class_name: Blazer.user_class.to_s if Blazer.user_class
    belongs_to :query

    validates :query_id, presence: true
    validate :validate_emails
    validate :validate_variables, if: -> { query_id_changed? }

    before_validation :fix_emails

    def split_emails
      emails.to_s.downcase.split(",").map(&:strip)
    end

    def split_slack_channels
      if Blazer.slack?
        slack_channels.to_s.downcase.split(",").map(&:strip)
      else
        []
      end
    end

    def update_state(result)
      self.last_run_at = Time.now if respond_to?(:last_run_at=)

      # do not notify on creation, except when not passing
      Blazer::ReportMailer.send_report(self, result.rows.size, result.error, result.columns, result.rows, result.column_types).deliver_now if emails.present?
      save! if changed?
    end

    private

      def fix_emails
        # some people like doing ; instead of ,
        # but we know what they mean, so let's fix it
        # also, some people like to use whitespace
        if emails.present?
          self.emails = emails.strip.gsub(/[;\s]/, ",").gsub(/,+/, ", ")
        end
      end

      def validate_emails
        unless split_emails.all? { |e| e =~ /\A\S+@\S+\.\S+\z/ }
          errors.add(:base, "Invalid emails")
        end
      end

      def validate_variables
        if query.variables.any?
          errors.add(:base, "Query can't have variables")
        end
      end
  end
end
