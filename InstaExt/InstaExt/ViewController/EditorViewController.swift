import UIKit

class EditorViewController: UIViewController {

    @IBOutlet weak var sourceImageView: UIImageView!
    @IBOutlet weak var filterImageView: UIImageView!
    @IBOutlet weak var toolView: UIView!
    @IBOutlet weak var toolSlider: UISlider!
    
    var selectedFilter: FilterType?
    var sourceImage: UIImage?
    
    private var filterImage: UIImage?

    // MARK: - Life cycle
    
    override func viewWillAppear(_ animated: Bool) {
        prepareTool()
        processFilter()
    }
    
    override func viewDidLayoutSubviews() {
        guard filterImageView.mask == nil else {
            return
        }
        
        let maskView = MaskView(frame: filterImageView.frame)
        maskView.maskImageView.frame = filterImageView.bounds
        view.addSubview(maskView)
        filterImageView.mask = maskView.maskImageView
    }
    
    // MARK: - @IBAction
    
    @IBAction func sliderAction(_ sender: UISlider) {
        processFilter()
    }
    
    // MARK: - @objc
    
    @objc func cancelAction() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func doneAction() {
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
        
        sourceImageView.image = sourceImage
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
    
    private func processFilter() {
        guard let sourceImage = sourceImage, let selectedFilter = selectedFilter else {
            return
        }
        filterImage = selectedFilter.filter().process(value: CGFloat(toolSlider.value),
                                                      image: sourceImage)
        filterImageView.image = filterImage
    }
}
