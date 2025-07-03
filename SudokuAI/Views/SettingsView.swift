import SwiftUI

struct SettingsView: View {
    @State private var selectedLevel = SystemSettings.level
    @State private var prerelease = SystemSettings.prerelease
    @State private var useSound = SystemSettings.useSound
    @State private var showIncorrect = SystemSettings.showIncorrect
    @State private var keyboardSwapSides = SystemSettings.keyboardSwapSides
    @State private var showRowColSelector = SystemSettings.showRowColSelector
    @State private var completeLastNumber = SystemSettings.completeLastNumber
    @State private var usageTracking = SystemSettings.usageTracking
    @State private var useHaptics = SystemSettings.useHaptics
    @State private var showTimer = SystemSettings.showTimer

    var body: some View {
        Form {
            Section(header: Text("Level")) {
                Picker("Level", selection: $selectedLevel) {
                    ForEach(PuzzleLevel.allCases, id: \.self) { level in
                        Text(level.description).tag(level)
                    }
                }
                .onChange(of: selectedLevel) { _, newValue in
                    SystemSettings.level = newValue
                }
            }
            Section(header: Text("Features")) {
                Toggle("Show Row/Col Selector", isOn: $showRowColSelector)
                    .onChange(of: showRowColSelector) { _, value in SystemSettings.showRowColSelector = value }
                Toggle("Complete Last Number", isOn: $completeLastNumber)
                    .onChange(of: completeLastNumber) { _, value in SystemSettings.completeLastNumber = value }
                Toggle("Show Incorrect Guesses", isOn: $showIncorrect)
                    .onChange(of: showIncorrect) { _, value in SystemSettings.showIncorrect = value }
                Toggle("Keyboard Swap Sides", isOn: $keyboardSwapSides)
                    .onChange(of: keyboardSwapSides) { _, value in SystemSettings.keyboardSwapSides = value }
                Toggle("Show Timer", isOn: $showTimer)
                    .onChange(of: showTimer) { _, value in SystemSettings.showTimer = value }
            }
            Section(header: Text("Audio & Haptics")) {
                Toggle("Use Sound", isOn: $useSound)
                    .onChange(of: useSound) { _, value in SystemSettings.useSound = value }
                Toggle("Use Haptics", isOn: $useHaptics)
                    .onChange(of: useHaptics) { _, value in SystemSettings.useHaptics = value }
            }
            Section(header: Text("Debug")) {
                Toggle("Prerelease Features", isOn: $prerelease)
                    .onChange(of: prerelease) { _, value in SystemSettings.prerelease = value }
                Toggle("Usage Tracking", isOn: $usageTracking)
                    .onChange(of: usageTracking) { _, value in SystemSettings.usageTracking = value }
            }
        }
    }
}

#Preview {
    SettingsView()
}
