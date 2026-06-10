//
//  constants.swift
//  Kit
//
//  Created by Serhiy Mytrovtsiy on 15/04/2020.
//  Using Swift 5.0.
//  Running on macOS 10.15.
//
//  Copyright © 2020 Serhiy Mytrovtsiy. All rights reserved.
//

import Cocoa

public let systemWidgetDiskWritesEnabled = true
public let systemWidgetDiskWriteInterval: TimeInterval = 60
public let systemWidgetActiveThreshold: TimeInterval = (systemWidgetDiskWriteInterval * 2) + 10
public let networkUsageTotalStoreKey = "Network_usageTotal"

public final class DiskWriteThrottle {
    public static let shared = DiskWriteThrottle()
    
    private let queue = DispatchQueue(label: "eu.exelban.Stats.DiskWriteThrottle")
    private var lastWrites: [String: Date] = [:]
    
    private init() {}
    
    public func shouldWrite(_ key: String, interval: TimeInterval = systemWidgetDiskWriteInterval, force: Bool = false) -> Bool {
        self.queue.sync {
            guard !force, let lastWrite = self.lastWrites[key] else { return true }
            return Date().timeIntervalSince(lastWrite) >= interval
        }
    }
    
    public func markWritten(_ key: String, at date: Date = Date()) {
        self.queue.sync {
            self.lastWrites[key] = date
        }
    }
}

public func touchWidgetActivity(_ defaults: UserDefaults?, _ key: String) {
    guard systemWidgetDiskWritesEnabled else { return }
    
    let now = Date().timeIntervalSince1970
    let lastUpdate = defaults?.double(forKey: key) ?? 0
    guard now - lastUpdate >= systemWidgetDiskWriteInterval else { return }
    
    defaults?.set(now, forKey: key)
}

public struct Popup_c_s {
    public let width: CGFloat = 264
    public let height: CGFloat = 300
    public let margins: CGFloat = 8
    public let spacing: CGFloat = 2
    public let headerHeight: CGFloat = 42
    public let separatorHeight: CGFloat = 30
    public let portalHeight: CGFloat = 120
    public let radius: CGFloat = 6
}

public struct Settings_c_s {
    public let width: CGFloat = 540
    public let height: CGFloat = 480
    public let margin: CGFloat = 10
}

public struct Widget_c_s {
    public let width: CGFloat = 32
    public var height: CGFloat {
        get {
            let systemHeight = NSApplication.shared.mainMenu?.menuBarHeight
            return (systemHeight == 0 ? 22 : systemHeight) ?? 22
        }
    }
    public var margin: CGPoint {
        get { CGPoint(x: 0, y: 2) }
    }
    public let spacing: CGFloat = 2
}

public struct Constants {
    public static let Popup: Popup_c_s = Popup_c_s()
    public static let Settings: Settings_c_s = Settings_c_s()
    public static let Widget: Widget_c_s = Widget_c_s()
    
    public static let defaultProcessIcon = NSWorkspace.shared.icon(forFile: "/bin/bash")
}

public enum ModuleType: Int {
    case CPU
    case RAM
    case GPU
    case disk
    case sensors
    case network
    case battery
    case bluetooth
    case clock
    case remote
    
    case combined
    
    public var stringValue: String {
        switch self {
        case .CPU: return "CPU"
        case .RAM: return "RAM"
        case .GPU: return "GPU"
        case .disk: return "Disk"
        case .sensors: return "Sensors"
        case .network: return "Network"
        case .battery: return "Battery"
        case .bluetooth: return "Bluetooth"
        case .clock: return "Clock"
        case .remote: return "Remote"
        case .combined: return ""
        }
    }
}
