import UIKit
import Vision

class FaceDetection {
    var delegate: FaceDetectionDelegate?

    lazy private var faceDetectionRequest = VNDetectFaceRectanglesRequest(completionHandler: self.handleDetectedFaces)

    func request(image: UIImage) {
        let orientation = CGImagePropertyOrientation(rawValue: UInt32(image.imageOrientation.rawValue))
        guard let cgImage = image.cgImage,
              let cgOrientation = orientation else {
            return
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
            return
        }
    }

    // MARK: - private

    private func handleDetectedFaces(request: VNRequest?, error: Error?) {
        guard let results = request?.results as? [VNFaceObservation] else {
            print("顔認識に失敗: \(error!)")
            self.detectionErrorAlert()
            return
        }

        var faces: [CGRect] = []
        for observation in results {
            faces.append(observation.boundingBox)
        }
        delegate?.didGetFaces(faces: faces)
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
    func didGetFaces(faces: [CGRect])
}
