import UIKit

class Monochrome: Filter {
    func process(value: CGFloat, image: UIImage) -> UIImage {
        let orientation = image.imageOrientation
        guard let inputCIImage = CIImage(image: image) else {
            fatalError("CIImageへの変換に失敗")
        }

        let monochromeFilter = CIFilter(name: "CIColorMonochrome")!
        monochromeFilter.setValue(inputCIImage, forKey: "inputImage")
        monochromeFilter.setValue(CIColor(red: value, green: value, blue: value), forKey: "inputColor")
        monochromeFilter.setValue(1, forKey: "inputIntensity")

        guard let monochromeImage = monochromeFilter.outputImage,
              let cgImage = CIContext().createCGImage(monochromeImage, from: monochromeImage.extent) else { fatalError("CGImageの書き出しに失敗") }

        let resultImage = UIImage(cgImage: cgImage, scale: 0, orientation: orientation)
        return resultImage
    }
}
