import Foundation
import CoreGraphics

final class TranslationService {
    private let apiKey: String

    init(apiKey: String) {
        self.apiKey = apiKey
    }

    func translate(
        texts: [OCRTextBox],
        source: String,
        target: String,
        completion: @escaping ([TranslatedText]) -> Void
    ) {
        guard !texts.isEmpty else {
            completion([])
            return
        }

        let textsToTranslate = texts.map { $0.text }

        let urlString = "https://translation.googleapis.com/language/translate/v2?key=\(apiKey)"
        guard let url = URL(string: urlString) else {
            print("❌ URL 생성 실패")
            completion([])
            return
        }

        let requestBody: [String: Any] = [
            "q": textsToTranslate,
            "source": source,
            "target": target,
            "format": "text"
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch {
            print("❌ 요청 본문 생성 실패: \(error)")
            completion([])
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data, error == nil else {
                print("❌ API 요청 에러: \(error?.localizedDescription ?? "알 수 없음")")
                completion([])
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let data = json["data"] as? [String: Any],
                   let translations = data["translations"] as? [[String: Any]] {

                    let translatedResults = zip(texts, translations).compactMap { (box, result) -> TranslatedText? in
                        guard let translatedText = result["translatedText"] as? String else { return nil }
                        return TranslatedText(
                            index: box.index,
                            original: box.text,
                            translated: translatedText,
                            frame: box.frame
                        )
                    }

                    completion(translatedResults)
                } else {
                    print("❌ 번역 결과 파싱 실패")
                    completion([])
                }
            } catch {
                print("❌ JSON 파싱 에러: \(error)")
                completion([])
            }
        }

        task.resume()
    }
}
