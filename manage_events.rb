module Api
  class ManageEvents

    def self.create_event(request_body, http_data)

      # {
      #   "dtstart": "2020-06-30T13:00:00Z",
      #   "signalName": "simple",
      #   "signalType": "level",
      #   "marketContext": "marketContext",
      #   "duration": 10,
      #   "paload": 1,
      #   "venId": "venId"
      # }

      response = {}

      begin
        vtn_namespace = VtnNamespace.first
        account = Account.first

        payload = JSON.parse(request_body)

        market_context = vtn_namespace.market_contexts.find_by_name!(payload.fetch('marketContext'))
        dtstart = Time.use_zone(account.time_zone) { Time.zone.parse(payload.fetch('dtstart')) }
        dtstart_str = dtstart.in_time_zone(account.time_zone).strftime("%Y-%m-%d %-l:%M%P")
        duration = payload.fetch('duration').to_i
        signal_name = SignalName.find_by_name!(payload.fetch('signalName'))
        signal_type = SignalType.find_by_name!(payload.fetch('signalType'))
        units = (payload.key?('units') ? EmixUnit.find_by_name(payload.fetch('units')) : nil)
        payload_value = payload.fetch('payload')

        event_id = (payload.key?('eventId') ? payload.fetch('eventId') : SecureRandom.hex(10))

        ven = vtn_namespace.vens.find_by_ven_id!(payload.fetch('venId'))

        ActiveRecord::Base.transaction do
          event = vtn_namespace.events.new(
              duration: duration,
              priority: 0,
              tolerance: 0,
              ei_notification: 0,
              ei_rampup: 0,
              ei_recovery: 0,
              event_id: event_id,
              vtn_comment: "",
              time_zone: account.time_zone,
              dtstart_str: dtstart_str
          )

          event.account = account

          event.dtstart = dtstart
          event.market_context = market_context
          event.response_required_type = ResponseRequiredType.find_by_name('always')

          event.save!

          #
          # add targets to event
          #
          event.targets << ven.targets.where(type: "VenId").first

          #
          # add a default signal
          #
          signal = event.event_signals.new

          signal.signal_id = SecureRandom.hex(10)
          signal.signal_name = signal_name
          signal.signal_type = signal_type

          signal.emix_unit = units

          signal.save!

          #
          # add default interval to signal
          #
          event_signal_interval = signal.event_signal_intervals.new

          event_signal_interval.uid = 0
          event_signal_interval.duration = event.duration
          event_signal_interval.payload = payload_value
          event_signal_interval.payload_type = PayloadType.find_by(value: 2)

          event_signal_interval.save!

          response = {
              status: "OK",
              event_id: event.event_id,
          }
        end # transaction

      rescue Exception => ex
        response = {
            status: "error",
            error_message: ex.message
        }
      end

      response.to_json
    end

    def self.cancel_event(request_body, http_data)

      response = {}

      begin
        vtn_namespace = VtnNamespace.first

        payload = JSON.parse(request_body)

        event_id = payload.fetch("eventId")

        event = vtn_namespace.events.find_by_event_id!(event_id)

        event.cancel
        event.publish

        response = {
            status: "OK",
        }

      rescue Exception => ex
        response = {
            status: "error",
            error_message: ex.message
        }
      end

      response.to_json
    end

    def self.delete_event(request_body, http_data)
      response = {}

      begin
        vtn_namespace = VtnNamespace.first

        payload = JSON.parse(request_body)

        event_id = payload.fetch("eventId")

        event = vtn_namespace.events.find_by_event_id!(event_id)

        event.delete

        response = {
            status: "OK",
        }

      rescue Exception => ex
        response = {
            status: "error",
            error_message: ex.message
        }
      end

      response.to_json
    end
  end
end