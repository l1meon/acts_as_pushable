require 'fcm'

module ActsAsPushable
  module FCM
    class Notification < ActsAsPushable::Notification
      def perform
        response = client.send([device.token], fcm_options)
        if response[:not_registered_ids].include? device.token
          device.update_attribute 'invalidated_at', Time.current
        end
        response
      end

      private

      attr_accessor :title, :click_action

      def client
        ::FCM.new(ActsAsPushable.configuration.fcm_key)
      end

      def fcm_options
        {
          notification: {
            title: title,
            body: message,
            click_action: click_action
          }.merge(payload)
        }
      end

      def title
        options.delete(:title)
      end
    end
  end
end
