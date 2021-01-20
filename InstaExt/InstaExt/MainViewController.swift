import UIKit
import PhotosUI

class MainViewController: UIViewController {

    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var initialLabel: UILabel!
    static var mainImage: UIImage = UIImage(named: "transparentImage")!
    let deviceC = Device()
    
    override func viewWillAppear(_ animated: Bool) {
       
    }
    
    @IBAction func takeInAction(_ sender: Any) {
        deviceC.takeInPhoto()
        mainImageView.image = MainViewController.mainImage
    }
}

protocol DeviceDelegate {
    func showPHPicker(phPicker: PHPickerViewController)
}

extension MainViewController: DeviceDelegate {
    func showPHPicker(phPicker: PHPickerViewController) {
        present(phPicker, animated: true)
    }
}
