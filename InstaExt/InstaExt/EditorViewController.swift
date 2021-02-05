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
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        prepareTool()
        processFilter()
    }
    
    override func viewDidLayoutSubviews() {
        let maskView = MaskView(frame: filterImageView.frame)
        maskView.maskImageView.frame = filterImageView.bounds
        self.view.addSubview(maskView)
        filterImageView.mask = maskView.maskImageView
    }
    
    // MARK: - @IBAction
    
    @IBAction func sliderAction(_ sender: UISlider) {
        processFilter()
    }
    
    // MARK: - private
    
    private func prepareTool() {
        guard let selectedFilter = selectedFilter else {
            return
        }
        
        sourceImageView.image = sourceImage
        navigationItem.title = selectedFilter.rawValue
        
        toolSlider.isContinuous = false
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

