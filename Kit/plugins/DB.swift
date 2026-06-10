//
//  DB.swift
//  Kit
//
//  Created by Serhiy Mytrovtsiy on 03/02/2024
//  Using Swift 5.0
//  Running on macOS 14.3
//
//  Copyright © 2024 Serhiy Mytrovtsiy. All rights reserved.
//

import Foundation

public class DB {
    public static let shared = DB()
    
    public var values: [String: Codable] {
        get { [:] }
        set {}
    }
    
    init() {
        self.migrateLegacyNetworkUsageTotal()
        self.removeLegacyStorage()
    }
    
    public func setup<T: Codable>(_ type: T.Type, _ key: String) {
        // Runtime samples are kept by readers and chart ring buffers, not by DB.
    }
    
    public func insert(key: String, value: Codable, ts: Bool = true, force: Bool = false) {}
    
    public func findOne<T: Decodable>(_ dynamicType: T.Type, key: String) -> T? {
        return nil
    }
    
    private func removeLegacyStorage() {
        let fileManager = FileManager.default
        
        for url in self.legacyStorageURLs() where fileManager.fileExists(atPath: url.path) {
            try? fileManager.removeItem(at: url)
        }
    }
    
    private func migrateLegacyNetworkUsageTotal() {
        guard Store.shared.data(key: networkUsageTotalStoreKey) == nil else { return }
        
        for url in self.legacyStorageURLs() where FileManager.default.fileExists(atPath: url.path) {
            guard let lldb = LLDB(url.path) else { continue }
            defer { lldb.close() }
            
            guard let raw = lldb.findOne("Network@UsageReader"),
                  let data = raw.data(using: .utf8),
                  let usage = try? JSONDecoder().decode(LegacyNetworkUsage.self, from: data),
                  let total = usage.total else { continue }
            
            let value = NetworkUsageTotalStore(upload: total.upload, download: total.download)
            guard let data = try? JSONEncoder().encode(value) else { continue }
            
            Store.shared.set(key: networkUsageTotalStoreKey, value: data)
            return
        }
    }
    
    private func legacyStorageURLs() -> [URL] {
        let fileManager = FileManager.default
        var urls: [URL] = []
        
        if let supportPath = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
            urls.append(supportPath.appendingPathComponent("Stats/lldb"))
        }
        urls.append(URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("Stats/lldb"))
        
        return urls
    }
}

private struct LegacyNetworkUsage: Decodable {
    let total: NetworkUsageTotalStore?
}

private struct NetworkUsageTotalStore: Codable {
    let upload: Int64
    let download: Int64
}
