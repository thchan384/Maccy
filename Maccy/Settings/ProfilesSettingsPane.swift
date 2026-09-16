import Defaults
import SwiftUI
import Settings

struct ProfilesSettingsPane: View {
  @Default(.activeProfile) private var activeProfile
  @Default(.profileNames) private var profileNames

  @State private var selection = ProfileDefaults.defaultProfileID
  @State private var newProfileName = ""
  @State private var showingAddProfileAlert = false
  @State private var showingDeleteProfileAlert = false

  var body: some View {
    Settings.Container(contentWidth: 680) {
      Settings.Section(title: "") {
        VStack(alignment: .leading, spacing: 20) {
          Text("Profiles allow you to keep your browsing separated. You may want to set up a profile for work or school.")
            .fixedSize(horizontal: false, vertical: true)
            .foregroundStyle(.secondary)

          HStack(alignment: .top, spacing: 16) {
            GroupBox {
              VStack(spacing: 8) {
                List(selection: $selection) {
                  ForEach(Array(profileNames.enumerated()), id: \.offset) { index, profile in
                    Label(
                      index == 0 ? "\(profile) (Default)" : profile,
                      systemImage: index == 0 ? "person.fill" : "person"
                    )
                    .tag(profileID(for: index, profileName: profile))
                  }
                }
                .listStyle(.plain)
                .onAppear {
                  if activeProfile == "All" {
                    activeProfile = ProfileDefaults.defaultProfileID
                  }
                  selection = activeProfile
                }
                .onChange(of: selection) { _, newValue in
                  guard !newValue.isEmpty else { return }
                  activeProfile = newValue
                  selection = newValue
                }

                HStack {
                  ControlGroup {
                    Button("", systemImage: "plus") {
                      showingAddProfileAlert = true
                    }
                    .help("Add profile")

                    Button("", systemImage: "minus") {
                      if activeProfile != ProfileDefaults.defaultProfileID {
                        showingDeleteProfileAlert = true
                      }
                    }
                    .help("Delete profile")
                    .disabled(activeProfile == ProfileDefaults.defaultProfileID)
                  }

                  Spacer(minLength: 0)
                }
              }
            } label: {
                if #available(macOS 26.0, *) {
                    Text("Profiles")
                      .font(.system(size: 13, weight: .semibold))
                } else {
                    // Fallback on earlier versions
                }            }
            .frame(height: 280, alignment: .top)
            .frame(maxWidth: .infinity)

            GroupBox {
              Form {
                TextField("Name:", text: profileNameBinding())
              }
              .formStyle(.columns)
            } label: {
                if #available(macOS 26.0, *) {
                    Text("Details")
                      .font(.system(size: 13, weight: .semibold))
                } else {
                    // Fallback on earlier versions
                }
            }
            .frame(height: 280, alignment: .top)
            .frame(maxWidth: .infinity)
          }
          .frame(height: 280)
        }
      }
    }
    .alert("Add profile", isPresented: $showingAddProfileAlert) {
      TextField("Profile name", text: $newProfileName)
      Button("Cancel", role: .cancel) { newProfileName = "" }
      Button("Add") {
        addProfile()
      }
      .disabled(newProfileName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
    }
    .alert(
      "Delete profile?",
      isPresented: $showingDeleteProfileAlert,
      presenting: activeProfile
    ) { profile in
      Button("Cancel", role: .cancel) {}
      Button("Delete", role: .destructive) {
        deleteProfile()
      }
    } message: { profile in
      Text("Delete \"\(displayName(for: profile))\"? This will remove the profile and switch back to the default.")
    }
  }

  private func profileID(for index: Int, profileName: String) -> String {
    index == 0 ? ProfileDefaults.defaultProfileID : profileName
  }

  private func displayName(for profileID: String) -> String {
    guard profileID != ProfileDefaults.defaultProfileID else {
      return profileNames.first ?? ProfileDefaults.defaultDisplayName
    }
    return profileID
  }

  private func profileNameBinding() -> Binding<String> {
    Binding(
      get: {
        if activeProfile == ProfileDefaults.defaultProfileID {
          return profileNames.first ?? ProfileDefaults.defaultDisplayName
        }
        return activeProfile
      },
      set: { newValue in
        let trimmed = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        var names = profileNames
        if activeProfile == ProfileDefaults.defaultProfileID {
          if names.indices.contains(0) {
            if names.dropFirst().contains(trimmed) {
              return
            }
            names[0] = trimmed
          } else {
            names.insert(trimmed, at: 0)
          }
          profileNames = names
          selection = ProfileDefaults.defaultProfileID
          return
        }

        guard let index = names.firstIndex(of: activeProfile) else { return }
        if names.contains(trimmed) && names.firstIndex(of: trimmed) != index {
          return
        }

        names[index] = trimmed
        profileNames = names
        activeProfile = trimmed
        selection = trimmed
      }
    )
  }

  private func addProfile() {
    let profileName = newProfileName.trimmingCharacters(in: .whitespacesAndNewlines)
    newProfileName = ""

    guard !profileName.isEmpty else { return }

    var names = profileNames
    if let index = names.firstIndex(of: profileName) {
      activeProfile = index == 0 ? ProfileDefaults.defaultProfileID : profileName
      selection = activeProfile
      return
    }

    names.append(profileName)
    profileNames = names
    activeProfile = profileName
    selection = profileName
  }

  private func deleteProfile() {
    guard activeProfile != ProfileDefaults.defaultProfileID else { return }

    profileNames = profileNames.filter { $0 != activeProfile }
    activeProfile = ProfileDefaults.defaultProfileID
    selection = ProfileDefaults.defaultProfileID
  }
}

#Preview {
  ProfilesSettingsPane()
    .environment(\.locale, .init(identifier: "en"))
}
