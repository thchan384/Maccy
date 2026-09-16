import AppIntents
import Defaults

struct GetCurrentProfile: AppIntent, CustomIntentMigratedAppIntent {
  static let intentClassName = "GetCurrentProfileIntent"
  static var openAppWhenRun: Bool { false }

  static var title: LocalizedStringResource = "Get Current Maccy Profile"
  static var description = IntentDescription("Returns the profile currently used by Maccy.")

  static var parameterSummary: some ParameterSummary {
    Summary("Get Current Maccy Profile")
  }

  func perform() async throws -> some IntentResult & ReturnsValue<String> {
    let profile = Defaults[.activeProfile]
    let displayName = profile == ProfileDefaults.defaultProfileID ? ProfileDefaults.defaultDisplayName : profile
    return .result(value: displayName)
  }
}
