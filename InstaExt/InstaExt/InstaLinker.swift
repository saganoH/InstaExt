import UIKit

class InstaLinker {
    func openApp(image: UIImage) {
        guard let instaUrl = URL(string: "instagram://") else {
            return
        }
        if UIApplication.shared.canOpenURL(instaUrl) {
            UIApplication.shared.open(instaUrl,
                                      options: [ : ],
                                      completionHandler: nil)
        } else {
            // インストールされていません　とアラート表示
        }
    }
}
