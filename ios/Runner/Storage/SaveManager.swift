import Foundation

public class SaveManager {
    public static let shared = SaveManager()
    private let defaults = UserDefaults.standard

    public var currentLevel: Int {
        get { defaults.integer(forKey: "current_level") == 0 ? 1 : defaults.integer(forKey: "current_level") }
        set { defaults.set(newValue, forKey: "current_level") }
    }

    public var maxUnlockedLevel: Int {
        get { defaults.integer(forKey: "max_unlocked_level") == 0 ? 1 : defaults.integer(forKey: "max_unlocked_level") }
        set { defaults.set(newValue, forKey: "max_unlocked_level") }
    }

    public var acorns: Int {
        get { defaults.integer(forKey: "acorns") }
        set { defaults.set(newValue, forKey: "acorns") }
    }

    public var soundEnabled: Bool {
        get { defaults.object(forKey: "sound_enabled") == nil ? true : defaults.bool(forKey: "sound_enabled") }
        set { defaults.set(newValue, forKey: "sound_enabled") }
    }

    public var musicEnabled: Bool {
        get { defaults.object(forKey: "music_enabled") == nil ? true : defaults.bool(forKey: "music_enabled") }
        set { defaults.set(newValue, forKey: "music_enabled") }
    }

    public var hapticsEnabled: Bool {
        get { defaults.object(forKey: "haptics_enabled") == nil ? true : defaults.bool(forKey: "haptics_enabled") }
        set { defaults.set(newValue, forKey: "haptics_enabled") }
    }

    public func getStars(for level: Int) -> Int {
        defaults.integer(forKey: "stars_lvl_\(level)")
    }

    public func saveLevelCompletion(level: Int, stars: Int, acornsEarned: Int) {
        let oldStars = getStars(for: level)
        if stars > oldStars {
            defaults.set(stars, forKey: "stars_lvl_\(level)")
        }
        acorns += acornsEarned
        if level == maxUnlockedLevel && maxUnlockedLevel < 200 {
            maxUnlockedLevel = level + 1
        }
        if level < 200 {
            currentLevel = level + 1
        }
    }
}
