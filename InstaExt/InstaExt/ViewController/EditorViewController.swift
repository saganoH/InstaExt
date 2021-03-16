import UIKit

class EditorViewController: UIViewController {

    @IBOutlet weak var frameView: UIView!
    @IBOutlet weak var toolView: UIView!

    var selectedFilter: FilterType?
    var sourceImage: UIImage?

    private var sourceImageView: UIImageView?
    private var filterImageView: UIImageView?
    private var filterImage: UIImage?

    private var toolSlider: UISlider?

    private let faceDetection = FaceDetection()
    private var maskView: MaskView? = nil

    // MARK: - Life cycle
    
    override func viewWillAppear(_ animated: Bool) {
        faceDetection.delegate = self
        prepareTool()
    }
    
    override func viewDidLayoutSubviews() {
        if filterImageView == nil {
            makeImageViews()
            processFilter()
        }
    }
    
    // MARK: - @objc

    @objc func changeModeAction(_ sender: UISegmentedControl) {
        guard let sourceImage = sourceImage else {
            return
        }

        if sender.selectedSegmentIndex == 1 {
            faceDetection.request(image: sourceImage)
        }

        maskView?.changeEditMode(mode: sender.selectedSegmentIndex)
    }

    @objc func sliderAction(_ sender: UISlider) {
        processFilter()
    }

    @objc func cancelAction() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func doneAction() {
        guard let sourceImageView = sourceImageView,
              let filterImageView = filterImageView else {
            return
        }

        let compositedImage = ImageComposition().process(source: sourceImageView,
                                                         filter: filterImageView)
        guard let resultImage = compositedImage,
              let navi = navigationController,
              let mainViewController = navi.viewControllers[(navi.viewControllers.count)-2] as? MainViewController else {
            fatalError("画像の編集確定に失敗")
        }
        mainViewController.setEditedImage(image: resultImage)
        navi.popViewController(animated: true)
    }
    
    // MARK: - private
    
    private func prepareTool() {
        makeTools()
        setNavigationItem()
    }

    private func makeTools() {
        toolSlider = UISlider()
        guard let toolSlider = toolSlider,
              let selectedFilter = selectedFilter else {
            return
        }
        let modeChanger = UISegmentedControl(items: ["描画", "顔認識"])

        toolView.addSubview(toolSlider)
        toolView.addSubview(modeChanger)

        toolSlider.addTarget(self, action: #selector(sliderAction(_:)), for: UIControl.Event.valueChanged)
        modeChanger.addTarget(self, action: #selector(changeModeAction(_:)), for: UIControl.Event.valueChanged)

        toolSlider.translatesAutoresizingMaskIntoConstraints = false
        modeChanger.translatesAutoresizingMaskIntoConstraints = false

        // toolViewに対してconstraintsを設定
        toolSlider.centerXAnchor.constraint(equalTo: toolView.centerXAnchor).isActive = true
        toolSlider.widthAnchor.constraint(equalToConstant: 300).isActive = true

        switch selectedFilter {
        case .blur, .mosaic:
            modeChanger.centerXAnchor.constraint(equalTo: toolView.centerXAnchor).isActive = true
            modeChanger.topAnchor.constraint(
                equalTo: toolView.topAnchor, constant: 20).isActive = true
            toolSlider.bottomAnchor.constraint(
                equalTo: toolView.bottomAnchor, constant: -20).isActive = true
        case .monochrome:
            modeChanger.isHidden = true
            toolSlider.centerYAnchor.constraint(equalTo: toolView.centerYAnchor).isActive = true
        }

        modeChanger.selectedSegmentIndex = 0
        toolSlider.isContinuous = false
        toolSlider.minimumTrackTintColor = UIColor.systemGray
        toolSlider.maximumValue = selectedFilter.max()
        toolSlider.minimumValue = selectedFilter.min()
        toolSlider.value = selectedFilter.mid()
    }

    private func setNavigationItem() {
        guard let selectedFilter = selectedFilter else {
            return
        }
        navigationItem.title = selectedFilter.rawValue

        let cancelButtonItem = UIBarButtonItem(image: UIImage(systemName: "xmark"),
                                               style: .plain,
                                               target: self,
                                               action: #selector(cancelAction))
        cancelButtonItem.tintColor = .label
        navigationItem.setLeftBarButton(cancelButtonItem, animated: true)

        let doneButtonItem = UIBarButtonItem(image: UIImage(systemName: "checkmark"),
                                             style: .plain,
                                             target: self,
                                             action: #selector(doneAction))
        doneButtonItem.tintColor = .label
        navigationItem.setRightBarButton(doneButtonItem, animated: true)
    }

    private func makeImageViews() {
        guard let sourceImage = sourceImage else {
            return
        }

        sourceImageView = UIImageView(frame: frameView.bounds.aspectFit(contentSize: sourceImage.size))
        guard let sourceImageView = sourceImageView else {
            return
        }
        sourceImageView.image = sourceImage
        sourceImageView.center = frameView.center
        view.addSubview(sourceImageView)

        filterImageView = UIImageView(frame: sourceImageView.frame)
        guard let filterImageView = filterImageView else {
            return
        }
        view.addSubview(filterImageView)

        maskView = MaskView(frame: filterImageView.frame)
        guard let maskView = maskView else {
            return
        }
        maskView.maskImageView.frame = filterImageView.bounds
        view.addSubview(maskView)

        filterImageView.mask = maskView.maskImageView
    }
    
    private func processFilter() {
        guard let sourceImage = sourceImage,
              let selectedFilter = selectedFilter,
              let filterImageView = filterImageView,
              let toolSlider = toolSlider else {
            return
        }
        filterImage = selectedFilter.filter().process(value: CGFloat(toolSlider.value),
                                                      image: sourceImage)
        filterImageView.image = filterImage
    }
}

// MARK: - FaceDetectionクラスのDelegate

extension EditorViewController: FaceDetectionDelegate {
    func showAlert(alert: UIAlertController) {
        DispatchQueue.main.async { [weak self] in
            self?.present(alert, animated: true)
        }
    }

    func didGetFaces(faces: [CGRect]) {
        guard let sourceImageView = sourceImageView else {
            return
        }

        let faceRects = convertFaceScale(from: faces, to: sourceImageView.bounds)

        maskView?.maskFaces(faceBounds: faceRects)
    }

    private func convertFaceScale(from normRects: [CGRect], to baseRect: CGRect) -> [CGRect] {
        var convertedRects: [CGRect] = []

        for normRect in normRects {
            let faceWidth = normRect.size.width * baseRect.width
            let faceHeight = normRect.size.height * baseRect.height
            let faceX = normRect.origin.x * baseRect.width
            let faceY = (1 - normRect.origin.y) * baseRect.height - faceHeight
            let convertedRect = CGRect(x: faceX, y: faceY, width: faceWidth, height: faceHeight)
            convertedRects.append(convertedRect)
        }
        return convertedRects
    }
}

// MARK: - CGRect Extension

fileprivate extension CGRect {
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
