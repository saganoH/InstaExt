import Foundation

enum ImageType: String {
    // heicはjpgとして読み込まれる
    case jpg = "jpeg"
    case png = "png"
    case pvt = "pvt"
}

extension URL {
    func imageTypeForExtention() -> ImageType {
        let ext = self.pathExtension.lowercased()
        
        switch ext {
        case "jpg", "jpeg":
            return .jpg
        case "png":
            return .png
        case "pvt":
            return .pvt
        default:
            print("サポート外の拡張子")
            return .jpg
        }
    }
}
