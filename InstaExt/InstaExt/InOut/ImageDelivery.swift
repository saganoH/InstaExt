import PhotosUI

class ImageDelivery: NSObject {
    
    weak var delegate: ImageDeliveryDelegate?

    private var imageType: ImageType = .jpg

    // MARK: - public

    func takeInPhoto() {
        var config = PHPickerConfiguration(photoLibrary: PHPhotoLibrary.shared())
        config.filter = .images
        config.selectionLimit = 1
        
        let phPicker = PHPickerViewController(configuration: config)
        phPicker.delegate = self

        delegate?.showPHPicker(phPicker: phPicker)
    }
    
    func savePhoto(image: UIImage, completion: @escaping (UIAlertController) -> Void) {
        let image = imageConversion(source: image)

        let alert = UIAlertController(title: "保存",
                                      message: "この画像を保存しますか？",
                                      preferredStyle: .alert)

        let okAction = UIAlertAction(title: "OK", style: .default, handler: { [weak self] (ok) in
            guard let self = self else { return }
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.showResultOfSaveImage( _:didFinishSavingWithError:contextInfo:)), nil)
        })
        let cancelAction = UIAlertAction(title: "CANCEL", style: .default, handler: { (cancel) in
            alert.dismiss(animated: true, completion: nil)
        })

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

    // MARK: - private

    private func imageConversion(source: UIImage) -> UIImage {
        let data: Data?

        switch imageType {
        case .png:
            data = source.pngData()
        case .jpg, .pvt:
            data = source.jpegData(compressionQuality: 1.0)
        }

        guard let convertedData = data,
              let convertedImage = UIImage(data: convertedData) else { return source }

        return convertedImage
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
        guard let identifier = provider.registeredTypeIdentifiers.first else { return }
        provider.loadItem(forTypeIdentifier: identifier, options: nil, completionHandler: { (url, error) in
            if let url = url as? URL {
                let type = url.imageTypeForExtention()
                self.imageType = type
            }

            provider.loadObject(ofClass: UIImage.self, completionHandler: { [weak self] (selectedImage, error) in
                guard let self = self else { return }
                guard error == nil, let wrapImage = selectedImage as? UIImage else {
                    self.makePickerAlert(completion: { (alert) in self.delegate?.showAlert(alert: alert) })
                    return
                }
                self.delegate?.didGetImage(image: wrapImage)
            })
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

protocol ImageDeliveryDelegate: AnyObject {
    func showPHPicker(phPicker: PHPickerViewController)
    func didGetImage(image: UIImage)
    func showAlert(alert: UIAlertController)
}
