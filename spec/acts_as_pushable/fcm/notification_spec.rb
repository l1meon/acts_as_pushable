require 'rails_helper'

RSpec.describe ActsAsPushable::FCM::Notification do
  context 'given a device' do
    before do
      user = User.create!
      @device = ActsAsPushable::Device.create!({
        token: SecureRandom.uuid,
        platform: 'ios',
        platform_version: '9.3',
        push_environment: 'development',
        parent: user,
      })
    end

    describe '#send' do
      it 'calls send on fcm' do
        expect_any_instance_of(FCM).to receive(:send).once.and_return({ not_registered_ids: [] })
        ActsAsPushable::FCM::Notification.send(device: @device, title: 'My App',
                                               message: 'this is a test',
                                               popup_title: "this is a test",
                                               view_id: '1234-5678-9012-3456')
      end

      it 'can invalidate a device' do
        Timecop.freeze(Time.parse('2016-01-01')) do
          expect_any_instance_of(FCM).to receive(:send).once.and_return({ not_registered_ids: [@device.token] })
          ActsAsPushable::FCM::Notification.send(device: @device, title: 'My App', message: 'this is a test', popup_title: "this is a test")
          @device.reload
          expect(@device.invalidated_at).to eq(Time.current)
        end
      end
    end
  end
end
