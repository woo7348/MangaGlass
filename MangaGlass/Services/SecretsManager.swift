//
//  SecretsManager.swift
//  MangaGlass
//
//  Created by 강민우 on 7/3/25.
//

import Foundation

final class SecretsManager {
    static let shared = SecretsManager()

    private var secrets: [String: Any] = [:]

    private init() {
        loadSecrets()
    }

    private func loadSecrets() {
        guard
            let url = Bundle.main.url(forResource: "Secrets", withExtension: "plist"),
            let data = try? Data(contentsOf: url),
            let plist = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil),
            let dict = plist as? [String: Any]
        else {
            print("❌ Secrets.plist 로드 실패")
            return
        }

        self.secrets = dict
    }

    // ✅ 이 부분 추가
    var apiKey: String {
        secrets["GoogleAPIKey"] as? String ?? ""
    }
}
