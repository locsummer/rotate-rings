import Foundation
import UIKit
import AudioToolbox

public class SoundManager {
    public static let shared = SoundManager()

    public var soundEnabled: Bool = true
    public var hapticsEnabled: Bool = true

    private let selectionFeedback = UISelectionFeedbackGenerator()
    private let impactLight = UIImpactFeedbackGenerator(style: .light)
    private let impactMedium = UIImpactFeedbackGenerator(style: .medium)
    private let notificationFeedback = UINotificationFeedbackGenerator()

    public func playTouch() {
        guard hapticsEnabled else { return }
        selectionFeedback.selectionChanged()
    }

    public func playRotateTick() {
        guard hapticsEnabled else { return }
        impactLight.impactOccurred()
    }

    public func playReleasePop() {
        guard soundEnabled || hapticsEnabled else { return }
        if soundEnabled {
            AudioServicesPlaySystemSound(1104) // Pop click
        }
        if hapticsEnabled {
            impactMedium.impactOccurred()
        }
    }

    public func playVictory() {
        guard soundEnabled || hapticsEnabled else { return }
        if soundEnabled {
            AudioServicesPlaySystemSound(1025) // Fanfare chime
        }
        if hapticsEnabled {
            notificationFeedback.notificationOccurred(.success)
        }
    }
}
