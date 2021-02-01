import UIKit
import PhotosUI

class MainViewController: UIViewController {

    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var initialLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
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

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource

extension MainViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let bokashiCell = collectionView.dequeueReusableCell(withReuseIdentifier: "bokashi", for: indexPath)
        bokashiCell.backgroundColor = UIColor.black
        return bokashiCell
    }
    
    // 編集機能の選択時に呼ばれる
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyboard = self.storyboard!
        let editorViewController = storyboard.instantiateViewController(identifier: "editorViewController") as! EditorViewController
        // editorViewController.selectedEditorName =
        switch indexPath.hashValue {
        case 0:
            editorViewController.selectedEditorName = "bokashi"
        default:
            print(indexPath.hashValue)
        }
        
        self.present(editorViewController, animated: true)
    }
}
