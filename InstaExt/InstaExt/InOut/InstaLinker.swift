import UIKit
import Photos

class InstaLinker: NSObject {

    var delegate: InstaLinkerDelegate?
    
    func link(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(afterSave(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @objc private func afterSave(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        
        let fetchResult = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: fetchOptions)
        guard let lastAsset = fetchResult.lastObject,
              let urlScheme = URL(string: "instagram://library?LocalIdentifier=\(lastAsset.localIdentifier)") else {
            self.delegate?.failedToLink(with: makeAlert(title: "Instagram連携エラー", message: "画像取得に失敗しました"))
            return
        }
        
        if UIApplication.shared.canOpenURL(urlScheme) {
            UIApplication.shared.open(urlScheme)
        } else {
            self.delegate?.failedToLink(with: makeAlert(title: "Instagram連携エラー", message: "アプリがインストールされていません"))
        }
    }
    
    private func makeAlert(title: String, message: String) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        return alert
    }
}

// MARK: - InstaLinkerDelegate protocol

protocol InstaLinkerDelegate {
    func failedToLink(with alert: UIAlertController)
}

