//
//  OCRService.swift
//  MangaGlass
//
//  Created by 강민우 on 6/26/25.
//

//import Foundation
//import AppKit
//import CoreGraphics
//
//final class OCRService {
//    private let apiKey = SecretsManager.shared.apiKey
//
//    func recognizeText(from image: NSImage, completion: @escaping ([OCRTextBox]) -> Void) {
//        // NSImage → CGImage 변환
//        guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
//            print("❌ NSImage → CGImage 변환 실패")
//            completion([])
//            return
//        }
//
//        // base64 JPEG 인코딩
//        guard let base64Image = cgImage.toBase64JPEG() else {
//            print("❌ 이미지 인코딩 실패")
//            completion([])
//            return
//        }
//
//        // Vision API URL 구성
//        let urlString = "https://vision.googleapis.com/v1/images:annotate?key=\(apiKey)"
//        guard let url = URL(string: urlString) else {
//            print("❌ Vision API URL 생성 실패")
//            completion([])
//            return
//        }
//
//        // 요청 본문 구성
//        let requestBody: [String: Any] = [
//            "requests": [[
//                "image": ["content": base64Image],
//                "features": [["type": "TEXT_DETECTION"]],
//                "imageContext": ["languageHints": ["ja"]] // 일본어 OCR
//            ]]
//        ]
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//
//        do {
//            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
//        } catch {
//            print("❌ JSON 직렬화 실패: \(error)")
//            completion([])
//            return
//        }
//
//        // API 호출
//        URLSession.shared.dataTask(with: request) { data, _, error in
//            guard let data = data, error == nil else {
//                print("❌ Vision API 요청 실패: \(error?.localizedDescription ?? "알 수 없음")")
//                completion([])
//                return
//            }
//
//            do {
//                let apiResponse = try JSONDecoder().decode(GoogleVisionResponse.self, from: data)
//
//                // 병합된 전체 텍스트만 추출
//                guard let fullText = apiResponse.responses.first?.textAnnotations?.first?.description,
//                      !fullText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
//                    print("⚠️ 병합 텍스트 없음")
//                    completion([])
//                    return
//                }
//
//                let box = OCRTextBox(
//                    text: fullText,
//                    frame: CGRect.zero,
//                    index: 0 // 또는 다른 방식으로 인덱스 부여
//                )
//
//                completion([box])
//            } catch {
//                print("❌ Vision API 응답 파싱 실패: \(error)")
//                completion([])
//            }
//        }.resume()
//    }
//}
//
//// MARK: - CGImage → base64 JPEG 인코딩
//
//extension CGImage {
//    func toBase64JPEG() -> String? {
//        let bitmapRep = NSBitmapImageRep(cgImage: self)
//        guard let jpegData = bitmapRep.representation(using: .jpeg, properties: [:]) else {
//            return nil
//        }
//        return jpegData.base64EncodedString()
//    }
//}
//
//// MARK: - Google Vision API 모델
//
//struct GoogleVisionResponse: Codable {
//    let responses: [VisionResponse]
//}
//
//struct VisionResponse: Codable {
//    let textAnnotations: [VisionAnnotation]?
//}
//
//struct VisionAnnotation: Codable {
//    let description: String
//    let boundingPoly: BoundingPoly?
//
//    struct BoundingPoly: Codable {
//        let vertices: [Vertex]
//
//        var boundingBox: CGRect? {
//            let xs = vertices.compactMap { $0.x }
//            let ys = vertices.compactMap { $0.y }
//
//            guard let minX = xs.min(), let maxX = xs.max(),
//                  let minY = ys.min(), let maxY = ys.max() else {
//                return nil
//            }
//
//            return CGRect(
//                x: CGFloat(minX),
//                y: CGFloat(minY),
//                width: CGFloat(maxX - minX),
//                height: CGFloat(maxY - minY)
//            )
//        }
//    }
//
//    struct Vertex: Codable {
//        let x: Double?
//        let y: Double?
//    }
//}

//
//  OCRService.swift
//  MangaGlass
//
//  Created by 강민우 on 6/26/25.
//

import Foundation
import AppKit
import CoreGraphics

final class OCRService {
    private let apiKey = SecretsManager.shared.apiKey

    func recognizeText(from image: NSImage, completion: @escaping ([OCRTextBox]) -> Void) {
        // NSImage → CGImage 변환
        guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            print("❌ NSImage → CGImage 변환 실패")
            completion([])
            return
        }

        // base64 JPEG 인코딩
        guard let base64Image = cgImage.toBase64JPEG() else {
            print("❌ 이미지 인코딩 실패")
            completion([])
            return
        }

        // Vision API URL 구성
        let urlString = "https://vision.googleapis.com/v1/images:annotate?key=\(apiKey)"
        guard let url = URL(string: urlString) else {
            print("❌ Vision API URL 생성 실패")
            completion([])
            return
        }

        // 요청 본문 생성
        let requestBody: [String: Any] = [
            "requests": [[
                "image": ["content": base64Image],
                "features": [["type": "TEXT_DETECTION"]],
                "imageContext": ["languageHints": ["ja"]] // 일본어 OCR
            ]]
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch {
            print("❌ JSON 직렬화 실패: \(error)")
            completion([])
            return
        }

        // 비동기 요청 실행
        URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data, error == nil else {
                print("❌ Vision API 요청 실패: \(error?.localizedDescription ?? "알 수 없음")")
                completion([])
                return
            }

            do {
                let apiResponse = try JSONDecoder().decode(GoogleVisionResponse.self, from: data)
                let annotations = apiResponse.responses.first?.textAnnotations ?? []

                guard annotations.count > 1 else {
                    print("⚠️ 텍스트 없음 또는 매우 짧음")
                    completion([])
                    return
                }

                // 첫 항목은 전체 텍스트이므로 제외
                let boxes = Array(annotations.dropFirst()).enumerated().compactMap { (i, annotation) -> OCRTextBox? in
                    guard let box = annotation.boundingPoly?.boundingBox else { return nil }
                    return OCRTextBox(
                        text: annotation.description,
                        frame: box,
                        index: i
                    )
                }
                completion(boxes)
            } catch {
                print("❌ Vision API 응답 파싱 실패: \(error)")
                completion([])
            }
        }.resume()
    }
}

// MARK: - CGImage → base64 JPEG 인코딩
extension CGImage {
    func toBase64JPEG() -> String? {
        let bitmapRep = NSBitmapImageRep(cgImage: self)
        guard let jpegData = bitmapRep.representation(using: .jpeg, properties: [:]) else {
            return nil
        }
        return jpegData.base64EncodedString()
    }
}

// MARK: - Google Vision API 응답 구조
struct GoogleVisionResponse: Codable {
    let responses: [VisionResponse]
}

struct VisionResponse: Codable {
    let textAnnotations: [VisionAnnotation]?
}

struct VisionAnnotation: Codable {
    let description: String
    let boundingPoly: BoundingPoly?

    struct BoundingPoly: Codable {
        let vertices: [Vertex]

        var boundingBox: CGRect? {
            let xs = vertices.compactMap { $0.x }
            let ys = vertices.compactMap { $0.y }

            guard let minX = xs.min(), let maxX = xs.max(),
                  let minY = ys.min(), let maxY = ys.max() else {
                return nil
            }

            return CGRect(
                x: CGFloat(minX),
                y: CGFloat(minY),
                width: CGFloat(maxX - minX),
                height: CGFloat(maxY - minY)
            )
        }
    }

    struct Vertex: Codable {
        let x: Double?
        let y: Double?
    }
}
