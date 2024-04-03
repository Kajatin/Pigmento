//
//  Haptics.swift
//  Pigmento
//
//  Created by Roland Kajatin on 03/04/2024.
//

import CoreHaptics
import Foundation

class HapticsManager: ObservableObject {
    @Published var engine: CHHapticEngine?

    /// HapticsManager is a singleton
    static let shared = HapticsManager()

    private init() {
        startHaptics()
    }

    func startHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else {
            return
        }

        do {
            engine = try CHHapticEngine()
            try engine?.start()
        } catch {
            print("There was an error creating the engine: \(error.localizedDescription)")
        }
    }

    func stopHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else {
            return
        }

        engine?.stop()
        engine = nil
    }

    func playHaptics(intensity: Float = 1, sharpness: Float = 1) {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else {
            return
        }

        var events = [CHHapticEvent]()

        events.append(
            CHHapticEvent(eventType: .hapticTransient, parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: sharpness)
            ], relativeTime: 0)
        )

        do {
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            print("Failed to play pattern: \(error.localizedDescription).")

            stopHaptics()
            startHaptics()
        }
    }
}
