import AppIntents
import Defaults

struct SetProfile: AppIntent, CustomIntentMigratedAppIntent {
  static let intentClassName = "SetProfileIntent"
  static var openAppWhenRun: Bool { false }

  static var title: LocalizedStringResource = "Set Maccy Profile"
  static var description = IntentDescription("Switches Maccy to a clipboard history profile.")

  static var parameterSummary: some ParameterSummary {
    Summary("Set Maccy Profile to \(\.$profile)")
  }

  @Parameter(title: "Profile")
  var profile: String

  func perform() async throws -> some IntentResult & ReturnsValue<String> {
    let profileID = ProfileDefaults.isDefault(profile)
      ? ProfileDefaults.defaultProfileID
      : profile

    guard Defaults[.profileNames].contains(profile) || ProfileDefaults.isDefault(profile) else {
      throw AppIntentError.profileNotFound
    }

    Defaults[.activeProfile] = profileID
    return .result(value: profile == ProfileDefaults.defaultProfileID ? ProfileDefaults.defaultDisplayName : profile)
  }
}
