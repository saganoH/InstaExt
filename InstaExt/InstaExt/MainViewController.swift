import UIKit
import PhotosUI

class MainViewController: UIViewController {

    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var initialLabel: UILabel!
    private var mainImage: UIImage = UIImage(named: "transparentImage")!
    private let deviceC = Device()
    
    override func viewWillAppear(_ animated: Bool) {
        deviceC.delegate = self
    }
    
    @IBAction func takeInAction(_ sender: Any) {
        deviceC.takeInPhoto()
    }
}

protocol DeviceDelegate {
    func showPHPicker(phPicker: PHPickerViewController)
    func didGetImage(gotImage: UIImage)
}

extension MainViewController: DeviceDelegate {
    func showPHPicker(phPicker: PHPickerViewController) {
        DispatchQueue.main.async {
            self.present(phPicker, animated: true)
        }
    }
    
    func didGetImage(gotImage: UIImage) {
        mainImage = gotImage
        DispatchQueue.main.async {
            self.mainImageView.image = self.mainImage
            self.initialLabel.isHidden = true
        }
    }
}
