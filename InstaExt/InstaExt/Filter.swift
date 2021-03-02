import UIKit

enum FilterType: String, CaseIterable {
    case blur = "ぼかし"
    case mosaic = "モザイク"
    case monochrome = "モノクロ"
    
    func max() -> Float {
        switch self {
        case .blur:
            return 20
        case .mosaic:
            return 30
        case .monochrome:
            return 1
        }
    }
    
    func min() -> Float {
        switch self {
        case .blur:
            return 0
        case .mosaic:
            return 1
        case .monochrome:
            return 0
        }
    }
    
    func mid() -> Float {
        return (max() + min()) / 2
    }
    
    func filter() -> Filter {
        switch self {
        case .blur:
            return Blur()
        case .mosaic:
            return Mosaic()
        case .monochrome:
            return Monochrome()
        }
    }
}

protocol Filter {
    func process(value: CGFloat, image: UIImage) -> UIImage
}
