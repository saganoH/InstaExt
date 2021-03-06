import UIKit
import PhotosUI

class MainViewController: UIViewController {
    
    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var initialLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var instaButton: UIBarButtonItem!

    private let imageDelivery = ImageDelivery()
    private let instaLinker = InstaLinker()
    private let editorNames = FilterType.allCases
    private let functionIcons: [UIImage] = [
        UIImage(named: "blur")!,
        UIImage(named: "mosaic")!,
        UIImage(named: "monochrome")!
    ]
    
    override func viewWillAppear(_ animated: Bool) {
        imageDelivery.delegate = self
        instaLinker.delegate = self
        
        if mainImageView.image == nil {
            saveButton.isEnabled = false
            instaButton.isEnabled = false
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        imageDelivery.delegate = nil
        instaLinker.delegate = nil
    }
    
    // MARK: - @IBAction
    
    @IBAction func takeInAction(_ sender: Any) {
        if mainImageView.image != nil {
            let alert = UIAlertController(title: "新規画像取り込み",
                                          message: "編集中画像を破棄してもよろしいですか？",
                                          preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default) { (ok) in
                self.imageDelivery.takeInPhoto()
            }
            let cancelAction = UIAlertAction(title: "CANCEL", style: .default) { (cancel) in
                alert.dismiss(animated: true, completion: nil)
            }

            alert.addAction(cancelAction)
            alert.addAction(okAction)
            self.present(alert, animated: true)
            return
        }

        if PHPhotoLibrary.authorizationStatus(for: .readWrite) == .authorized {
            self.imageDelivery.takeInPhoto()
            return
        }
        
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { [weak self] (status) in
            guard let self = self else { return }
            switch status {
            case .authorized, .limited:
                self.imageDelivery.takeInPhoto()
            case .denied:
                self.showAuthAlert()
            default:
                print("写真のアクセス権限に変更があった可能性")
            }
        }
    }
    
    @IBAction func saveAction(_ sender: Any) {
        if let image = mainImageView.image {
            imageDelivery.savePhoto(image: image, completion: { [weak self] (alert) in
                                        guard let self = self else { return }
                                        self.showAlert(alert: alert) })
        }
    }
    
    @IBAction func linkInstagram(_ sender: Any) {
        if let image = mainImageView.image {
            instaLinker.link(image: image)
        }
    }
    
    // MARK: - public
    
    func setEditedImage(image: UIImage) {
        mainImageView.image = image
        initialLabel.isHidden = true
    }
    
    // MARK: - private
    
    private func showAuthAlert() {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "写真のアクセス権限がありません",
                                          message: "すべての写真を許可してください",
                                          preferredStyle: .alert)
            let setting = UIAlertAction(title: "設定",
                                        style: .default,
                                        handler: { (_) -> Void in
                                            guard let settingsURL = URL(string: UIApplication.openSettingsURLString ) else {
                                                return
                                            }
                                            UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
                                        })
            alert.addAction(setting)
            self.present(alert, animated: true)
        }
    }
}

// MARK: - ImageDeliveryクラスのDelegate

extension MainViewController: ImageDeliveryDelegate {
    func showPHPicker(phPicker: PHPickerViewController) {
        DispatchQueue.main.async { [weak self] in
            self?.present(phPicker, animated: true)
        }
    }
    
    func didGetImage(image: UIImage) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.mainImageView.image = image
            self.initialLabel.isHidden = true
            self.saveButton.isEnabled = true
            self.instaButton.isEnabled = true
            
            // TODO: - cellの無効化切り替え時に色変更
            for cell in self.collectionView.visibleCells {
                cell.isUserInteractionEnabled = true
            }
        }
    }
    
    func showAlert(alert: UIAlertController) {
        DispatchQueue.main.async { [weak self] in
            self?.present(alert, animated: true)
        }
    }
}

// MARK: - InstaLinkerクラスのDelegate

extension MainViewController: InstaLinkerDelegate {
    func failedToLink(with alert: UIAlertController) {
        DispatchQueue.main.async { [weak self] in
            self?.present(alert, animated: true)
        }
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource

extension MainViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    // cell情報
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        
        cell.backgroundColor = UIColor.systemBackground
        cell.layer.borderColor = CGColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 0.7)
        cell.layer.borderWidth = 1.0
        cell.layer.cornerRadius = cell.frame.size.width * 0.5
        cell.clipsToBounds = true
        
        let functionIconFrame = CGRect(x: cell.frame.height / 2,
                                       y: cell.frame.height / 2,
                                       width: cell.frame.height / 2,
                                       height: cell.frame.height / 2)
        let functionIcon = UIImageView(frame: functionIconFrame)
        functionIcon.image = functionIcons[indexPath.item]
        cell.contentView.addSubview(functionIcon)
        
        let functionLabel = UILabel(frame: cell.bounds)
        functionLabel.textAlignment = .center
        functionLabel.text = editorNames[indexPath.item].rawValue
        cell.contentView.addSubview(functionLabel)
        
        cell.isUserInteractionEnabled = false
        return cell
    }
    
    // 編集機能の選択時に呼ばれる
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let storyboard = storyboard,
              let editorViewController = storyboard.instantiateViewController(identifier: "editorViewController") as? EditorViewController else {
            fatalError("画面遷移先の取得に失敗")
        }
        editorViewController.selectedFilter = editorNames[indexPath.item]
        editorViewController.sourceImage = mainImageView.image        
        navigationController?.pushViewController(editorViewController, animated: true)
    }
}
