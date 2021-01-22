import PhotosUI

class ImageDelivery {
    
    var delegate: DeviceDelegate?
    
    func takeInPhoto() {
        var config = PHPickerConfiguration(photoLibrary: PHPhotoLibrary.shared())
        
        config.filter = .images
        config.selectionLimit = 1
        
        let phPicker = PHPickerViewController(configuration: config)
        phPicker.delegate = self
        
        self.delegate?.showPHPicker(phPicker: phPicker)
    }
}

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
            let alert = UIAlertController(title: "その画像は読み込めません", message: "ファイルが破損している可能性があります", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            completion(alert)
        }
    }
}
