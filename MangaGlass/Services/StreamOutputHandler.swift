import ScreenCaptureKit
import AVFoundation
import VideoToolbox
import AppKit

class StreamOutputHandler: NSObject, SCStreamOutput {
    weak var state: AppState?

    init(state: AppState) { self.state = state }

    func stream(_ stream: SCStream, didOutputSampleBuffer sampleBuffer: CMSampleBuffer, of type: SCStreamOutputType) {
        guard type == .screen else { return }
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            print("❌ sampleBuffer에서 이미지 버퍼 추출 실패")
            return
        }

        var cgImage: CGImage?
        let status = VTCreateCGImageFromCVPixelBuffer(pixelBuffer, options: [:] as CFDictionary, imageOut: &cgImage)

        if status == noErr, let cgImage = cgImage {
            let nsImage = NSImage(cgImage: cgImage, size: .zero)

            DispatchQueue.main.async {
                self.state?.capturedImage = nsImage
                // OCR/번역 호출 제거! -> 이미지 전달만
            }
        } else {
            print("❌ CGImage 변환 실패")
        }
    }
}
