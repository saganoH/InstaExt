import PhotosUI

class Device {
    
    private var delegate: DeviceDelegate?
    
    func takeInPhoto() {
        var config = PHPickerConfiguration(photoLibrary: PHPhotoLibrary.shared())

        // 画像のみ選択可能に設定
        config.filter = .images
        // 選択できる数を指定
        config.selectionLimit = 1

        // configを渡して初期化
        let phPicker = PHPickerViewController(configuration: config)
        // delegateをセット
        phPicker.delegate = self

        // 表示
        self.delegate?.showPHPicker(phPicker: phPicker)
    }
    
}

extension Device: PHPickerViewControllerDelegate {
    // Pickerを閉じたときにコールされる
    public func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
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
                
                MainViewController.mainImage = wrapImage
            }
        }
    }
}
