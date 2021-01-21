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
}

protocol DeviceDelegate {
    func showPHPicker(phPicker: PHPickerViewController)
    func didGetImage(gotImage: UIImage)
    func showAlert(alert: UIAlertController)
}

extension MainViewController: DeviceDelegate {
    func showPHPicker(phPicker: PHPickerViewController) {
        DispatchQueue.main.async {
            self.present(phPicker, animated: true)
        }
    }
    
    func didGetImage(gotImage: UIImage) {
        DispatchQueue.main.async {
            self.mainImageView.image = gotImage
            self.initialLabel.isHidden = true
        }
    }
    
    func showAlert(alert: UIAlertController) {
        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
    }
}
