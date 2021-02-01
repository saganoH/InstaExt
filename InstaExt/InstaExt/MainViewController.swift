import UIKit
import PhotosUI

class MainViewController: UIViewController {

    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var initialLabel: UILabel!
    private let imageDelivery = ImageDelivery()
    
    override func viewWillAppear(_ animated: Bool) {
        imageDelivery.delegate = self
    }
    
    // MARK: - @IBAction
    
    @IBAction func takeInAction(_ sender: Any) {
        imageDelivery.takeInPhoto()
    }
    
    @IBAction func saveAction(_ sender: Any) {
        if let image = mainImageView.image {
            imageDelivery.savePhoto(image: image, completion: { [weak self] (alert) in
                                        guard let self = self else { return }
                                        self.showAlert(alert: alert) })
        }
    }
}

// MARK: - DeviceクラスのDelegate

extension MainViewController: ImageDeliveryDelegate {
    func showPHPicker(phPicker: PHPickerViewController) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.present(phPicker, animated: true)
        }
    }
    
    func didGetImage(image: UIImage) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.mainImageView.image = image
            self.initialLabel.isHidden = true
        }
    }
    
    func showAlert(alert: UIAlertController) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.present(alert, animated: true)
        }
    }
}
