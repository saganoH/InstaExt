import PhotosUI

class Device {
    
    var delegate: DeviceDelegate?
    
    func takeInPhoto() {
        var config = PHPickerConfiguration(photoLibrary: PHPhotoLibrary.shared())

        // 画像のみ選択可能に設定
        config.filter = .images
        // 選択できる数を指定
        config.selectionLimit = 1

        // configを渡して初期化
        let phPicker = PHPickerViewController(configuration: config)
        phPicker.delegate = self

        self.delegate?.showPHPicker(phPicker: phPicker)
    }
    
}

extension Device: PHPickerViewControllerDelegate {
    // Pickerで選択したときにコールされる
    public func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        for image in results {
            // PHPickerResultからImageを読み込む
            image.itemProvider.loadObject(ofClass: UIImage.self) { (selectedImage, error) in
                if let error = error {
                    print("error: \(error.localizedDescription)")
                    return
                }
                // UIImageに変換
                guard let wrapImage = selectedImage as? UIImage else {
                    print("wrap error")
                    return
                }
                self.delegate?.didGetImage(gotImage: wrapImage)
            }
        }
    }
}
