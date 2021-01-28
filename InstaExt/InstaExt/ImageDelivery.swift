import PhotosUI

class ImageDelivery: NSObject {
    
    var delegate: DeviceDelegate?
    
    func takeInPhoto() {
        var config = PHPickerConfiguration(photoLibrary: PHPhotoLibrary.shared())
        
        config.filter = .images
        config.selectionLimit = 1
        
        let phPicker = PHPickerViewController(configuration: config)
        phPicker.delegate = self
        
        self.delegate?.showPHPicker(phPicker: phPicker)
    }
    
    func savePhoto(image: UIImage, completion: @escaping (UIAlertController) -> Void) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "保存", message: "この画像を保存しますか？", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default) { (ok) in
                UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.showResultOfSaveImage( _:didFinishSavingWithError:contextInfo:)), nil)
            }
            let cancelAction = UIAlertAction(title: "CANCEL", style: .default) { (cancel) in
                alert.dismiss(animated: true, completion: nil)
            }
            alert.addAction(cancelAction)
            alert.addAction(okAction)
            completion(alert)
        }
    }
    
    func showPrivacyAlert() {
        DispatchQueue.main.async {
            let alert = UIAlertController(
                title: "写真の追加権限がありません",
                message: "カメラロールへの追加を許可してください",
                preferredStyle: .alert)
            
            let settingsAction = UIAlertAction(
                title: "設定",
                style: .default,
                handler: { (_) -> Void in
                    guard let settingsURL = URL(string: UIApplication.openSettingsURLString ) else {
                        return
                    }
                    UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
                })
            
            let closeAction: UIAlertAction = UIAlertAction(
                title: "キャンセル",
                style: .cancel,
                handler: nil)
            
            alert.addAction(settingsAction)
            alert.addAction(closeAction)
            self.delegate?.showAlert(alert: alert)
        }
    }
    
    @objc func showResultOfSaveImage(_ image: UIImage, didFinishSavingWithError error: NSError!, contextInfo: UnsafeMutableRawPointer) {
        DispatchQueue.main.async {
            var title = "保存完了"
            var message = "カメラロールに保存しました"
            
            if error != nil {
                title = "エラー"
                message = "保存に失敗しました"
            }
            
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.delegate?.showAlert(alert: alert)
        }
    }
}

// MARK: - PHPickerViewControllerDelegate

extension ImageDelivery: PHPickerViewControllerDelegate {
    
    public func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        for image in results {
            // PHPickerResultからImageを読み込む
            image.itemProvider.loadObject(ofClass: UIImage.self, completionHandler: { [weak self] (selectedImage, error) in
                guard let self = self else { return }
                
                guard error == nil, let wrapImage = selectedImage as? UIImage else {
                    self.makePickerAlert(completion: { (alert) in self.delegate?.showAlert(alert: alert) })
                    return
                }
                self.delegate?.didGetImage(image: wrapImage)
            })
        }
    }
    
    private func makePickerAlert(completion: @escaping (UIAlertController) -> Void) {
        DispatchQueue.main.async {
            let alert = UIAlertController(
                title: "その画像は読み込めません",
                message: "ファイルが破損している可能性があります",
                preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            completion(alert)
        }
    }
}
