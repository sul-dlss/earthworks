# frozen_string_literal: true

require 'socket'

# Reports indexing events to SDR via message queue
class SdrEvents
  class << self
    def configure
      Dor::Event::Client.configure(**Settings.sdr_events.rabbitmq.to_h)
    end

    def enabled?
      Settings.sdr_events.enabled
    end

    def report_indexing_success(druid, target:)
      create_event(druid:, target:, type: 'earthworks_indexing_success')
    end

    def report_indexing_deleted(druid, target:)
      create_event(druid:, target:, type: 'earthworks_indexing_deleted')
    end

    def report_indexing_skipped(druid, target:, message:)
      create_event(druid:, target:, type: 'earthworks_indexing_skipped', data: { message: })
    end

    def report_indexing_errored(druid, target:, message:, context: nil)
      create_event(druid:, target:, type: 'earthworks_indexing_errored', data: { message:, context: }.compact)
    end

    private

    def create_event(druid:, target:, type:, data: {})
      return unless enabled?

      Dor::Event::Client.create(
        druid: "druid:#{druid}",
        type:,
        data: {
          target:,
          host:,
          invoked_by: 'publish_event'
        }.merge(data)
      )
    end

    def host
      @host ||= Socket.gethostname
    end
  end

  configure
end
