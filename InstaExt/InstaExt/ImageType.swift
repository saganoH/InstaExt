import Foundation

enum ImageType: String {
    case jpg = "jpeg"
    case png = "png"
    case heic = "heic"
    case pvt = "pvt"
}

extension URL {
    func imageTypeForExtention() -> ImageType? {
        let ext = self.pathExtension.lowercased()
        switch ext {
        case "jpg", "jpeg":
            return .jpg
        case "png":
            return .png
        case "heic":
            return .heic
        case "pvt":
            return .pvt
        default:
            return nil
        }
    }
}
