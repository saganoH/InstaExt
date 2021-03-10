import UIKit

class EditorViewController: UIViewController {

    @IBOutlet weak var tmpView: UIView!
    @IBOutlet weak var toolView: UIView!
    @IBOutlet weak var toolSlider: UISlider!
    @IBOutlet weak var modeChanger: UISegmentedControl!

    var selectedFilter: FilterType?
    var sourceImage: UIImage?

    private var sourceImageView: UIImageView?
    private var filterImageView: UIImageView?

    private let faceDetection = FaceDetection()
    private var faces: [CGRect] = []
    private var maskView: MaskView? = nil
    private var filterImage: UIImage?
    
    // MARK: - Life cycle
    
    override func viewWillAppear(_ animated: Bool) {
        faceDetection.delegate = self

        // TODO: - モノクロの場合はスライダとmodeChangerの位置調整する
        prepareTool()
    }
    
    override func viewDidLayoutSubviews() {
        if filterImageView == nil  {
            makeImageViews()
            processFilter()
        }
    }
    
    // MARK: - @IBAction
    
    @IBAction func changeModeAction(_ sender: UISegmentedControl) {
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

    @IBAction func sliderAction(_ sender: UISlider) {
        processFilter()
    }
    
    // MARK: - @objc
    
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
        
        toolSlider.isContinuous = false
        toolSlider.minimumTrackTintColor = UIColor.systemGray
        toolSlider.maximumValue = selectedFilter.max()
        toolSlider.minimumValue = selectedFilter.min()
        toolSlider.value = selectedFilter.mid()
    }

    private func makeImageViews() {
        guard let sourceImage = sourceImage else {
            return
        }

        sourceImageView = UIImageView(frame: tmpView.bounds.aspectFit(contentSize: sourceImage.size,
                                                                      stretchble: true,
                                                                      integer: true))
        guard let sourceImageView = sourceImageView else {
            return
        }
        sourceImageView.image = sourceImage
        sourceImageView.center = tmpView.center
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
              let filterImageView = filterImageView else {
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

        // サイズを変換する
        let faces = convertRectsSize(sourceRects: faces, imageView: sourceImageView)
        print(faces)

        // 矩形表示はこれから
        // 顔ぼかし
        maskView?.drawCycle(faceBounds: faces)
    }

    private func convertRectsSize(sourceRects: [CGRect], imageView: UIImageView) -> [CGRect] {
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
    func aspectFit(contentSize: CGSize, stretchble: Bool, integer: Bool) -> CGRect {
        let xZoom = width / contentSize.width
        let yZoom = height / contentSize.height
        let zoom = stretchble ? min(xZoom, yZoom) : min(xZoom, yZoom, 1)

        if integer {
            let newWidth = max(Int(contentSize.width * zoom), 1)
            let newHeight = max(Int(contentSize.height * zoom), 1)
            let newX = Int(origin.x) + (Int(width) - newWidth) / 2
            let newY = Int(origin.y) + (Int(height) - newHeight) / 2
            return CGRect(x: newX, y: newY, width: newWidth, height: newHeight)
        } else {
            let newWidth = contentSize.width * zoom
            let newHeight = contentSize.height * zoom
            let newX = origin.x + (width - newWidth) / 2
            let newY = origin.y + (height - newHeight) / 2
            return CGRect(x: newX, y: newY, width: newWidth, height: newHeight)
        }
    }
}
