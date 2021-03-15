import CoreGraphics

extension CGRect {
    func aspectFit(contentSize: CGSize) -> CGRect {
        let xRatio = width / contentSize.width
        let yRatio = height / contentSize.height
        let ratio = min(xRatio, yRatio)

        let newWidth = max(Int(contentSize.width * ratio), 1)
        let newHeight = max(Int(contentSize.height * ratio), 1)
        let newX = Int(origin.x) + (Int(width) - newWidth) / 2
        let newY = Int(origin.y) + (Int(height) - newHeight) / 2

        let newRect = CGRect(x: newX, y: newY, width: newWidth, height: newHeight)

        return newRect
    }
}
