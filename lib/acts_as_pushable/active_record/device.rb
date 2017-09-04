module ActsAsPushable
  class Device < ActiveRecord::Base
    belongs_to :parent, polymorphic: true

    validates :token, :platform, :valid_at, :parent, :platform_version, :push_environment, presence: true
    validates :token, uniqueness: true
    validates :active, inclusion: { in: [true, false] }

    before_validation :set_valid_at, on: :create
    before_validation :strip_spaces_from_token, on: :create, if: :token

    scope :active, -> { where(invalidated_at: nil, active: true) }

    default_scope { active }

    def ios?
      platform == 'ios'
    end

    def android?
      platform == 'Android'
    end

    def deactivate
      self.update_attributes({
        active: false,
        deactivated_at: Time.current,
      })
    end

    def send_push_notification(message:, **options)
      case platform
      when 'ios'
        ActsAsPushable::APN::Notification.send(device: self, message: message, **options)
      when 'Android'
        raise ArgumentError, 'missing keyword: title' unless options.key? :title
        unless options[:title].nil?
          ActsAsPushable::FCM::Notification.send(device: self, title: options[:title], message: message, **options)
        end
      end
    end

    private

    def set_valid_at
      self.valid_at = Time.current
    end

    def strip_spaces_from_token
      self.token = token.delete(' ')
    end
  end
end
