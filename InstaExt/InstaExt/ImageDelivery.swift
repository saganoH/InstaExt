import PhotosUI

class ImageDelivery: NSObject {
    
    var delegate: ImageDeliveryDelegate?
    
    func takeInPhoto() {
        var config = PHPickerConfiguration(photoLibrary: PHPhotoLibrary.shared())
        
        config.filter = .images
        config.selectionLimit = 1
        
        let phPicker = PHPickerViewController(configuration: config)
        phPicker.delegate = self

        delegate?.showPHPicker(phPicker: phPicker)
    }
    
    func savePhoto(image: UIImage, completion: @escaping (UIAlertController) -> Void) {
        let alert = UIAlertController(title: "保存",
                                      message: "この画像を保存しますか？",
                                      preferredStyle: .alert)

        let okAction = UIAlertAction(title: "OK", style: .default) { [weak self] (ok) in
            guard let self = self else { return }
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.showResultOfSaveImage( _:didFinishSavingWithError:contextInfo:)), nil)
        }
        let cancelAction = UIAlertAction(title: "CANCEL", style: .default) { (cancel) in
            alert.dismiss(animated: true, completion: nil)
        }

        alert.addAction(cancelAction)
        alert.addAction(okAction)
        completion(alert)
    }

    @objc func showResultOfSaveImage(_ image: UIImage, didFinishSavingWithError error: NSError!, contextInfo: UnsafeMutableRawPointer) {
        var title = "保存完了"
        var message = "カメラロールに保存しました"

        if error != nil {
            title = "保存エラー"
            message = "写真が保存できませんでした"
        }

        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.delegate?.showAlert(alert: alert)
    }
}

// MARK: - PHPickerViewControllerDelegate

extension ImageDelivery: PHPickerViewControllerDelegate {

    public func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)

        guard let provider = results.first?.itemProvider else {
            return
        }

        // 選択した画像のURLから拡張子を取得
        var imageType: ImageType = .jpg
        guard let identifier = provider.registeredTypeIdentifiers.first else { return }
        provider.loadItem(forTypeIdentifier: identifier, options: nil) { (url, error) in
            if let url = url as? URL {
                imageType = url.imageTypeForExtention()
            }
        }

        provider.loadObject(ofClass: UIImage.self, completionHandler: { [weak self] (selectedImage, error) in
            guard let self = self else { return }
            guard error == nil, let wrapImage = selectedImage as? UIImage else {
                self.makePickerAlert(completion: { (alert) in self.delegate?.showAlert(alert: alert) })
                return
            }
            self.delegate?.didGetImage(image: wrapImage, type: imageType)
        })
    }
    
    private func makePickerAlert(completion: @escaping (UIAlertController) -> Void) {
        let alert = UIAlertController(title: "その画像は読み込めません",
                                      message: "ファイルが破損している可能性があります",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        completion(alert)
    }
}

// MARK: - ImageDeliveryDelegate protocol

protocol ImageDeliveryDelegate {
    func showPHPicker(phPicker: PHPickerViewController)
    func didGetImage(image: UIImage, type: ImageType)
    func showAlert(alert: UIAlertController)
}
