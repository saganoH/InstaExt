import UIKit
import PhotosUI

class MainViewController: UIViewController {

    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var initialLabel: UILabel!
    private let imageDelivery = ImageDelivery()
    
    override func viewWillAppear(_ animated: Bool) {
        imageDelivery.delegate = self
    }
    
    @IBAction func takeInAction(_ sender: Any) {
        imageDelivery.takeInPhoto()
    }
    
    @IBAction func saveAction(_ sender: Any) {
        if let image = mainImageView.image {
            imageDelivery.savePhoto(image: image, completion: { (alert) in self.showAlert(alert: alert) })
        }
    }
}

protocol DeviceDelegate {
    func showPHPicker(phPicker: PHPickerViewController)
    func didGetImage(image: UIImage)
    func showAlert(alert: UIAlertController)
}

extension MainViewController: DeviceDelegate {
    func showPHPicker(phPicker: PHPickerViewController) {
        DispatchQueue.main.async {
            self.present(phPicker, animated: true)
        }
    }
    
    func didGetImage(image: UIImage) {
        DispatchQueue.main.async {
            self.mainImageView.image = image
            self.initialLabel.isHidden = true
        }
    }
    
    func showAlert(alert: UIAlertController) {
        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
    }
}
