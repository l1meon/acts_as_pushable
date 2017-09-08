require 'fcm'

module ActsAsPushable
  module FCM
    class Notification < ActsAsPushable::Notification
      def perform
        response = client.send([device.token], fcm_payload)
        if response[:not_registered_ids].include? device.token
          device.update_attribute 'invalidated_at', Time.current
        end
        response
      end

      private

      attr_accessor :title, :click_action, :tag

      def client
        ::FCM.new(ActsAsPushable.configuration.fcm_key)
      end

      def fcm_options
        {
          notification: {
            title: title,
            body: message,
            click_action: click_action,
            tag: tag
          }.merge(payload),
          data: {
              view_id: view_id,
          }
        }
      end

      def fcm_payload
        fcm_options.tap do |k|
         k[:notification].tap do |j|
           j.delete(:view_id)
         end
        end
      end



      def title
        options.delete(:title)
      end

      def view_id
        view_id = payload[:view_id]
        view_id
      end
    end
  end
end
