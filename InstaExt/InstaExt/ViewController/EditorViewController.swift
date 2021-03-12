import UIKit

class EditorViewController: UIViewController {

    @IBOutlet weak var frameView: UIView!
    @IBOutlet weak var toolView: UIView!

    var selectedFilter: FilterType?
    var sourceImage: UIImage?

    private var sourceImageView: UIImageView?
    private var filterImageView: UIImageView?
    private var filterImage: UIImage?

    private var modeChanger: UISegmentedControl?
    private var toolSlider: UISlider?

    private let faceDetection = FaceDetection()
    private var faces: [CGRect] = []
    private var maskView: MaskView? = nil

    // MARK: - Life cycle
    
    override func viewWillAppear(_ animated: Bool) {
        faceDetection.delegate = self
        prepareTool()
    }
    
    override func viewDidLayoutSubviews() {
        if filterImageView == nil  {
            makeImageViews()
            processFilter()
        }
    }
    
    // MARK: - @objc

    @objc func changeModeAction(_ sender: UISegmentedControl) {
        guard let sourceImage = sourceImage else {
            return
        }

        switch sender.selectedSegmentIndex {
        case 0:
            print("描画モード")
            maskView?.addGestureRecognizer(UIPanGestureRecognizer(target: maskView,
                                                                  action: #selector(maskView?.panAction(_:))))
        case 1:
            print("顔認識モード")
            maskView?.gestureRecognizers?.removeAll()
            faceDetection.request(image: sourceImage)
        default:
            fatalError("モードは2つのみ")
        }
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
        modeChanger = UISegmentedControl(items: ["描画", "顔認識"])
        guard let toolSlider = toolSlider,
              let modeChanger = modeChanger,
              let selectedFilter = selectedFilter else {
            return
        }

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

        // 正規化されたrect情報をimageViewのスケールに変換
        let faceRects = convertRects(sourceRects: faces, imageView: sourceImageView)

        maskView?.drawCycle(faceBounds: faceRects)
    }

    private func convertRects(sourceRects: [CGRect], imageView: UIImageView) -> [CGRect] {
        var convertedRects: [CGRect] = []

        for sourceRect in sourceRects {
            let width = sourceRect.size.width * imageView.bounds.width
            let height = sourceRect.size.height * imageView.bounds.height
            let x = sourceRect.origin.x * imageView.bounds.width
            let y = (1 - sourceRect.origin.y) * imageView.bounds.height - height
            let convertedRect = CGRect(x: x, y: y, width: width, height: height)
            convertedRects.append(convertedRect)
        }
        return convertedRects
    }
}

// MARK: - extension CGRect

extension CGRect {
    func aspectFit(contentSize: CGSize) -> CGRect {
        let xZoom = width / contentSize.width
        let yZoom = height / contentSize.height
        let zoom = min(xZoom, yZoom)

        let newWidth = max(Int(contentSize.width * zoom), 1)
        let newHeight = max(Int(contentSize.height * zoom), 1)
        let newX = Int(origin.x) + (Int(width) - newWidth) / 2
        let newY = Int(origin.y) + (Int(height) - newHeight) / 2

        let newRect = CGRect(x: newX, y: newY, width: newWidth, height: newHeight)
        
        return newRect
    }
}
