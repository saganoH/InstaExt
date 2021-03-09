import UIKit
import Vision

class FaceDetection {
    var delegate: FaceDetectionDelegate?

    lazy var faceDetectionRequest = VNDetectFaceRectanglesRequest(completionHandler: self.handleDetectedFaces)
    private var faces: [CGRect] = []

    func request(image: UIImage) -> [CGRect] {
        let orientation = CGImagePropertyOrientation(rawValue: UInt32(image.imageOrientation.rawValue))
        guard let cgImage = image.cgImage,
              let cgOrientation = orientation else {
            return faces
        }

        var requests: [VNRequest] = []
        requests.append(self.faceDetectionRequest)

        let imageRequestHandler = VNImageRequestHandler(cgImage: cgImage,
                                                        orientation: cgOrientation,
                                                        options: [:])

        do {
            try imageRequestHandler.perform(requests)
        } catch let error as NSError {
            print("リクエストの実行に失敗: \(error)")
            self.detectionErrorAlert()
            return faces
        }

        // リクエストの実行が完了してから返したい
        return faces
    }

    // MARK: - private

    private func handleDetectedFaces(request: VNRequest?, error: Error?) {
        if let nsError = error as NSError? {
            print("顔認識に失敗: \(nsError)")
            self.detectionErrorAlert()
            return
        }

        guard let results = request?.results as? [VNFaceObservation] else {
            return
        }
        for (index, observation) in results.enumerated() {
            faces[index] = observation.boundingBox
            print(index)
        }

        //        DispatchQueue.main.async {
        //            guard let drawLayer = self.pathLayer,
        //                let results = request?.results as? [VNFaceObservation] else {
        //                    return
        //            }
        //            self.draw(faces: results, onImageWithBounds: drawLayer.bounds)
        //            drawLayer.setNeedsDisplay()
        //        }
    }

    private func detectionErrorAlert() {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "顔認識エラー",
                                          message: "顔が検出できませんでした",
                                          preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK",
                                         style: .default) { _ in
            }
            alert.addAction(okAction)
            self.delegate?.showAlert(alert: alert)
        }
    }
}

// MARK: - FaceDetectionDelegate protocol

protocol FaceDetectionDelegate {
    func showAlert(alert: UIAlertController)
}
