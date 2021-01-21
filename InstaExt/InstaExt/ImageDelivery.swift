
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
            image.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] (selectedImage, error) in
                guard let self = self else { return }
                
                if let error = error {
                    print("error: \(error.localizedDescription)")
                    self.delegate?.showAlert(alert: self.makePickerAlert())
                    return
                }

                guard let wrapImage = selectedImage as? UIImage else {
                    self.delegate?.showAlert(alert: self.makePickerAlert())
                    return
                }
                self.delegate?.didGetImage(gotImage: wrapImage)
            }
        }
    }
    
    private func makePickerAlert() -> UIAlertController { 
        let alert = UIAlertController(title: "その画像は読み込めません", message: "ファイルが破損している可能性があります", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        return alert

    }
}
