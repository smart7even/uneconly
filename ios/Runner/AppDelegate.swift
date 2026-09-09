import EventKit
import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private var calendarSyncChannel: FlutterMethodChannel?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    let channel = FlutterMethodChannel(
      name: "com.roadmapik.uneconly/calendar_sync",
      binaryMessenger: engineBridge.applicationRegistrar.messenger()
    )
    channel.setMethodCallHandler(CalendarBatchSync.handle)
    calendarSyncChannel = channel
  }
}

private enum CalendarBatchSync {
  private static let queue = DispatchQueue(
    label: "com.roadmapik.uneconly.calendar-sync",
    qos: .utility
  )

  static func handle(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard call.method == "replaceEvents" else {
      result(FlutterMethodNotImplemented)
      return
    }
    guard
      let arguments = call.arguments as? [String: Any],
      let calendarName = arguments["calendarName"] as? String,
      let startMilliseconds = arguments["start"] as? NSNumber,
      let endMilliseconds = arguments["end"] as? NSNumber,
      let eventArguments = arguments["events"] as? [[String: Any]]
    else {
      result(
        FlutterError(
          code: "invalid_arguments",
          message: "Calendar sync arguments are invalid",
          details: nil
        )
      )
      return
    }

    queue.async {
      autoreleasepool {
        do {
          try replaceEvents(
            calendarName: calendarName,
            start: Date(timeIntervalSince1970: startMilliseconds.doubleValue / 1000),
            end: Date(timeIntervalSince1970: endMilliseconds.doubleValue / 1000),
            eventArguments: eventArguments
          )
          finish(result, value: true)
        } catch {
          finish(
            result,
            value: FlutterError(
              code: "calendar_sync_failed",
              message: error.localizedDescription,
              details: nil
            )
          )
        }
      }
    }
  }

  private static func replaceEvents(
    calendarName: String,
    start: Date,
    end: Date,
    eventArguments: [[String: Any]]
  ) throws {
    guard start < end else {
      throw CalendarSyncError.invalidDateRange
    }
    guard hasFullCalendarAccess else {
      throw CalendarSyncError.permissionDenied
    }

    let eventStore = EKEventStore()
    let calendar = try calendar(named: calendarName, in: eventStore)
    let predicate = eventStore.predicateForEvents(
      withStart: start,
      end: end,
      calendars: [calendar]
    )

    for event in eventStore.events(matching: predicate) {
      try eventStore.remove(event, span: .thisEvent, commit: false)
    }

    for arguments in eventArguments {
      guard
        let title = arguments["title"] as? String,
        let startMilliseconds = arguments["start"] as? NSNumber,
        let endMilliseconds = arguments["end"] as? NSNumber
      else {
        throw CalendarSyncError.invalidEvent
      }

      let event = EKEvent(eventStore: eventStore)
      event.calendar = calendar
      event.title = title
      event.notes = arguments["description"] as? String
      event.location = arguments["location"] as? String
      event.startDate = Date(
        timeIntervalSince1970: startMilliseconds.doubleValue / 1000
      )
      event.endDate = Date(
        timeIntervalSince1970: endMilliseconds.doubleValue / 1000
      )
      event.timeZone = TimeZone(identifier: "Europe/Moscow")
      event.addAlarm(EKAlarm(relativeOffset: -15 * 60))
      try eventStore.save(event, span: .thisEvent, commit: false)
    }

    try eventStore.commit()
  }

  private static func calendar(
    named name: String,
    in eventStore: EKEventStore
  ) throws -> EKCalendar {
    if let existing = eventStore.calendars(for: .event).first(where: {
      $0.title == name && $0.allowsContentModifications
    }) {
      return existing
    }

    guard
      let source = eventStore.defaultCalendarForNewEvents?.source
        ?? eventStore.sources.first(where: { $0.sourceType == .local })
        ?? eventStore.sources.first(where: { $0.sourceType == .calDAV })
    else {
      throw CalendarSyncError.calendarSourceUnavailable
    }

    let calendar = EKCalendar(for: .event, eventStore: eventStore)
    calendar.title = name
    calendar.source = source
    calendar.cgColor = UIColor(red: 0.05, green: 0.55, blue: 0.56, alpha: 1).cgColor
    try eventStore.saveCalendar(calendar, commit: true)
    return calendar
  }

  private static var hasFullCalendarAccess: Bool {
    let status = EKEventStore.authorizationStatus(for: .event)
    if #available(iOS 17.0, *) {
      return status == .fullAccess
    }
    return status == .authorized
  }

  private static func finish(_ result: @escaping FlutterResult, value: Any?) {
    DispatchQueue.main.async {
      result(value)
    }
  }
}

private enum CalendarSyncError: LocalizedError {
  case invalidDateRange
  case invalidEvent
  case permissionDenied
  case calendarSourceUnavailable

  var errorDescription: String? {
    switch self {
    case .invalidDateRange:
      return "Calendar sync date range is invalid"
    case .invalidEvent:
      return "A calendar event is invalid"
    case .permissionDenied:
      return "Full calendar access has not been granted"
    case .calendarSourceUnavailable:
      return "No writable calendar account is available"
    }
  }
}
