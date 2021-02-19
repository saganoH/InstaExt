import UIKit
import Photos

class InstaLinker: NSObject {
    func link(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(afterSave(_:didFinishSavingWithError:contextInfo:)), nil)
    }

    @objc private func afterSave(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        
        let fetchResult = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: fetchOptions)
        if (fetchResult.firstObject != nil) {
            guard let lastAsset = fetchResult.lastObject,
                  let urlScheme = URL(string: "instagram://library?LocalIdentifier=\(lastAsset.localIdentifier)") else {
                return
            }
            if UIApplication.shared.canOpenURL(urlScheme) {
                UIApplication.shared.open(urlScheme)
            } else {
                print("インストールされていません　とアラート表示入れる")
            }
        }
    }
}
