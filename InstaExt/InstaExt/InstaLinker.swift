import UIKit

class InstaLinker {
    func prepareLink(image: UIImage) -> URL? {
        guard let jpg = image.jpegData(compressionQuality: 1.0) as NSData? else {
            return nil
        }
        //let path = NSTemporaryDirectory() + "tmpImage.jpg"
        //let url: URL = NSURL(string: path)! as URL
        let url = FileManager.default.temporaryDirectory


        jpg.write(to: url, atomically: true)

        // url先には正しい画像が格納されている
        do {
            let data = try Data(contentsOf: url)
            let image = UIImage(data: data)!
        } catch let err {
            print("Error : \(err.localizedDescription)")
        }


        guard let instaUrl = URL(string: "instagram://library?LocalIdentifier=\(url)") else {
            return nil
        }

        print(FileManager.default.fileExists(atPath: url.path))
        if FileManager.default.fileExists(atPath: url.path) {
            do {
                // removeItemは機能している
                //try FileManager.default.removeItem(atPath: url.path)
            } catch {
                print("failed")
            }
        } else {
            print("ファイルがないよ")
        }
        print(FileManager.default.fileExists(atPath: url.path))

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

extension FileManager {
    func clearTmpDirectory() {
        do {
            let tmpDirURL = FileManager.default.temporaryDirectory
            let tmpDirectory = try contentsOfDirectory(atPath: tmpDirURL.path)
            try tmpDirectory.forEach { file in
                let fileUrl = tmpDirURL.appendingPathComponent(file)
                try removeItem(atPath: fileUrl.path)
            }
        } catch {
           //catch the error somehow
        }
    }

    func clearTmpDirectory(path: String) {
        do {
            let tmpDirURL = NSURL(string: path)! as URL
            let tmpDirectory = try contentsOfDirectory(atPath: tmpDirURL.path)
            try tmpDirectory.forEach { file in
                let fileUrl = tmpDirURL.appendingPathComponent(file)
                try removeItem(atPath: fileUrl.path)
            }
        } catch {
           //catch the error somehow
        }
    }
}
