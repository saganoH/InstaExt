import UIKit

class InstaLinker {
    func prepareLink(image: UIImage) -> URL? {
        guard let jpg = image.jpegData(compressionQuality: 1.0) as NSData? else {
            return nil
        }
        let path = NSTemporaryDirectory() + "tmpImage.jpg"
        let url: URL = NSURL(string: path)! as URL

        jpg.write(to: url, atomically: true)

        guard let instaUrl = URL(string: "instagram://library?LocalIdentifier=\(url)") else {
            return nil
        }
        return instaUrl
    }

    func openApp(instaUrl: URL) {

        if UIApplication.shared.canOpenURL(instaUrl) {
            UIApplication.shared.open(instaUrl,
                                      options: [ : ],
                                      completionHandler: nil)
        } else {
            // インストールされていません　とアラート表示
        }
    }
}
