//
//  PhotoEditToolView.swift
//  PrintImage
//
//  Created by Alex Tran on 9/8/25.
//

import UIKit

class PhotoEditToolView: UIView {
    
    // MARK: - UI Elements
    private let headerStackView = UIView()
    private let containerImageView = RotatableZoomImageView()
    private let collectionViewTool: UICollectionView
    private let collectionViewFilter: UICollectionView
    private let collectionViewEffect: UICollectionView
    private var photoToolSlider: CollectionViewPhotoTool?
    private let barBottomTool = UIView()
    private let context = CIContext()
    private let editStackView = UIStackView()
    private let effectStackView = UIStackView()
    private let effectLabel = UILabel()
    private var currentCollectionView : UICollectionView!
    private var filterView: FilterCollectionView?
    private var effectView: EffectCollectionView?
    private let adjustView = BrightnessSaturationView()
    private var focusImageView : FocusImageView!
    private let drawingToolView = DrawingToolView()
    private let drawingLayer = DrawingImageView()
    private var drawingLayerColorDetele : DrawingDeleteColorImageView?
    private var drawingDeleteColorView = DrawingDeleteColorView()
    private var curvesAdjustmentView = CurvesAdjustmentView()
    private var emojiSliderView = EmojiSliderView()
    private var stickerSliderView = StickerSliderView()
    private var textToolBarView = TextToolBarView()
    private var slideTextView = SlideTextView(initialPage: 1)
    
    
    private var currentImage : UIImage? = UIImage() {
        didSet {
            setupToolActions()
            if let img = currentImage {
                containerImageView.setImage(img)
            }
        }
    }
    private var stackFlip = UIStackView()
    // MARK: - Data
    private let photoEditToolModel = PhotoEditToolModel()
    private(set) var currentImageEdit: ImageEdited?
    
    // MARK: - Callbacks
    var closeView: (() -> Void)?
    
    // MARK: - Init
    override init(frame: CGRect) {
        let toolLayout = UICollectionViewFlowLayout()
        toolLayout.scrollDirection = .horizontal
        toolLayout.minimumLineSpacing = 2
        collectionViewTool = UICollectionView(frame: .zero, collectionViewLayout: toolLayout)
        
        let filterLayout = UICollectionViewFlowLayout()
        filterLayout.scrollDirection = .horizontal
        filterLayout.minimumLineSpacing = 2
        collectionViewFilter = UICollectionView(frame: .zero, collectionViewLayout: filterLayout)
        
        let effectLayout = UICollectionViewFlowLayout()
        effectLayout.scrollDirection = .horizontal
        effectLayout.minimumLineSpacing = 2
        collectionViewEffect = UICollectionView(frame: .zero, collectionViewLayout: effectLayout)
        
        super.init(frame: frame)
        
        
        setupUI()
        setupConstraints()
        setupToolActions()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Setup
    private func setupUI() {
        backgroundColor = .clear
        translatesAutoresizingMaskIntoConstraints = false
        currentImage = currentImageEdit?.imageEdited
        // Header
        headerStackView.translatesAutoresizingMaskIntoConstraints = false
        headerStackView.backgroundColor = .darkGray
        addSubview(headerStackView)
        
        // Container Image
        containerImageView.translatesAutoresizingMaskIntoConstraints = false
        containerImageView.backgroundColor = .clear
        addSubview(containerImageView)
        
        // Bottom Tool Bar
        barBottomTool.translatesAutoresizingMaskIntoConstraints = false
        barBottomTool.backgroundColor = .darkGray
        addSubview(barBottomTool)
        
        // adjustView
        adjustView.translatesAutoresizingMaskIntoConstraints = false
        adjustView.backgroundColor = .darkGray
        adjustView.isHidden = true
        addSubview(adjustView)
        
        
        // Tool Collection
        photoToolSlider = CollectionViewPhotoTool(collectionView: collectionViewTool)
        
        // Filter View
        filterView = FilterCollectionView(collectionView: collectionViewFilter)
        collectionViewFilter.isHidden = true
        
        
        // Effect View
        effectView = EffectCollectionView(collectionView: collectionViewEffect)
        collectionViewEffect.isHidden = true
        
        emojiSliderView.isHidden = true
        stickerSliderView.isHidden = true
        [collectionViewTool,collectionViewFilter,collectionViewEffect,emojiSliderView,stickerSliderView].forEach{
            $0.backgroundColor = .clear
            $0.translatesAutoresizingMaskIntoConstraints = false
            barBottomTool.addSubview($0)
        }
        
        // flipStackView
        let config = UIImage.SymbolConfiguration(pointSize: 30, weight: .regular) // 40 là kích thước
        let flipHorizontalIcon = UIImage(systemName: "arrow.trianglehead.left.and.right.righttriangle.left.righttriangle.right.fill", withConfiguration: config)
        
        let btnH = UIButton(type: .system)
        btnH.setImage(flipHorizontalIcon, for: .normal)
        btnH.tintColor = .white
        btnH.addTarget(self, action: #selector(flipH), for: .touchUpInside)
        
        // Nút lật dọc
        let flipVericalIcon = UIImage(systemName: "arrow.trianglehead.up.and.down.righttriangle.up.righttriangle.down.fill", withConfiguration: config)
        let btnV = UIButton(type: .system)
        btnV.setImage(flipVericalIcon, for: .normal)
        btnV.tintColor = .white
        btnV.addTarget(self, action: #selector(flipV), for: .touchUpInside)
        stackFlip.axis = .horizontal
        stackFlip.translatesAutoresizingMaskIntoConstraints = false
        stackFlip.spacing = 20
        stackFlip.distribution = .equalSpacing
        stackFlip.addArrangedSubview(btnH)
        stackFlip.addArrangedSubview(btnV)
        stackFlip.isHidden = true
        stackFlip.alignment = .center
        barBottomTool.addSubview(stackFlip)
        
        
        // drawing tool
        drawingToolView.translatesAutoresizingMaskIntoConstraints = false
        barBottomTool.addSubview(drawingToolView)
        drawingToolView.isHidden = true
        
        //drawingDeleteColorView
        
        drawingDeleteColorView.translatesAutoresizingMaskIntoConstraints = false
        barBottomTool.addSubview(drawingDeleteColorView)
        drawingDeleteColorView.isHidden = true
        
        // drawing in image
        drawingLayer.isUserInteractionEnabled = true
        containerImageView.imageView.isUserInteractionEnabled = true
        drawingLayer.frame = containerImageView.imageView.bounds
        drawingLayer.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        containerImageView.imageView.addSubview(drawingLayer)
        drawingLayer.isHidden = true
        
        // curvesAdjustmentView
        curvesAdjustmentView.translatesAutoresizingMaskIntoConstraints = false
        curvesAdjustmentView.layer.zPosition = 999
        self.addSubview(curvesAdjustmentView)
        self.bringSubviewToFront(curvesAdjustmentView)
        curvesAdjustmentView.isHidden = true
        
        
        //textToolBarView
        textToolBarView.translatesAutoresizingMaskIntoConstraints = false
        textToolBarView.backgroundColor = .clear
        textToolBarView.isHidden = true
        barBottomTool.addSubview(textToolBarView)
        slideTextView.layer.zPosition = 999
        slideTextView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(slideTextView)
        // Stack Views
        setupStackViews()
        
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Header
            headerStackView.topAnchor.constraint(equalTo: topAnchor),
            headerStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            headerStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            headerStackView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.05),
            
            // Image Container
            containerImageView.topAnchor.constraint(equalTo: headerStackView.bottomAnchor),
            containerImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerImageView.bottomAnchor.constraint(equalTo: barBottomTool.topAnchor),
            
            // Bottom Tool Bar
            barBottomTool.leadingAnchor.constraint(equalTo: leadingAnchor),
            barBottomTool.trailingAnchor.constraint(equalTo: trailingAnchor),
            barBottomTool.bottomAnchor.constraint(equalTo: bottomAnchor),
            barBottomTool.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.12),
            
            
            // adjustView
            adjustView.leadingAnchor.constraint(equalTo: leadingAnchor),
            adjustView.trailingAnchor.constraint(equalTo: trailingAnchor),
            adjustView.bottomAnchor.constraint(equalTo: bottomAnchor),
            adjustView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.12),
            
            stackFlip.widthAnchor.constraint(equalTo: barBottomTool.widthAnchor,multiplier: 0.3),
            stackFlip.heightAnchor.constraint(equalTo: barBottomTool.heightAnchor),
            stackFlip.centerXAnchor.constraint(equalTo: barBottomTool.centerXAnchor),
            
            drawingToolView.widthAnchor.constraint(equalTo: barBottomTool.widthAnchor,multiplier: 0.8),
            drawingToolView.heightAnchor.constraint(equalTo: barBottomTool.heightAnchor),
            drawingToolView.centerXAnchor.constraint(equalTo: barBottomTool.centerXAnchor),
            
            drawingDeleteColorView.widthAnchor.constraint(equalTo: barBottomTool.widthAnchor,multiplier: 0.8),
            drawingDeleteColorView.heightAnchor.constraint(equalTo: barBottomTool.heightAnchor),
            drawingDeleteColorView.centerXAnchor.constraint(equalTo: barBottomTool.centerXAnchor),
            
            curvesAdjustmentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            curvesAdjustmentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            curvesAdjustmentView.bottomAnchor.constraint(equalTo: bottomAnchor),
            curvesAdjustmentView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.3),
            
            
            textToolBarView.widthAnchor.constraint(equalTo: barBottomTool.widthAnchor,multiplier: 0.7),
            textToolBarView.heightAnchor.constraint(equalTo: barBottomTool.heightAnchor),
            textToolBarView.centerXAnchor.constraint(equalTo: barBottomTool.centerXAnchor),
            
            slideTextView.leadingAnchor.constraint(equalTo: leadingAnchor),
            slideTextView.trailingAnchor.constraint(equalTo: trailingAnchor),
            slideTextView.bottomAnchor.constraint(equalTo: barBottomTool.topAnchor,constant: 0),
            slideTextView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.2),
        ])
        
        [collectionViewTool,collectionViewFilter,collectionViewEffect,emojiSliderView,stickerSliderView].forEach{
            NSLayoutConstraint.activate([
                $0.leadingAnchor.constraint(equalTo: barBottomTool.leadingAnchor, constant: 16),
                $0.trailingAnchor.constraint(equalTo: barBottomTool.trailingAnchor, constant: -16),
                $0.topAnchor.constraint(equalTo: barBottomTool.topAnchor, constant: 0),
                $0.heightAnchor.constraint(equalTo: barBottomTool.heightAnchor)
            ])
        }
    }
    
    private func setupStackViews() {
        func configStack(_ stack: UIStackView) {
            stack.axis = .horizontal
            stack.distribution = .equalCentering
            stack.alignment = .center
            stack.translatesAutoresizingMaskIntoConstraints = false
        }
        
        configStack(editStackView)
        configStack(effectStackView)
        
        let editBtnCancel = UIButton()
        let editLabel = UILabel()
        let editComplete = UIButton()
        
        let effectBtnCancel = UIButton()
        let effectComplete = UIButton()
        
        editBtnCancel.setTitle("Huỷ", for: .normal)
        editComplete.setTitle("Hoàn tất", for: .normal)
        effectBtnCancel.setTitle("Quay lại", for: .normal)
        effectComplete.setTitle("Ok", for: .normal)
        
        editBtnCancel.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        effectBtnCancel.addTarget(self, action: #selector(backView), for: .touchUpInside)
        
        editLabel.text = "Chỉnh sửa"
        
        [editBtnCancel, editComplete, effectBtnCancel, effectComplete].forEach {
            $0.setTitleColor(.white, for: .normal)
            $0.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        }
        [effectLabel, editLabel].forEach {
            $0.textColor = .white
            $0.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        }
        
        editStackView.addArrangedSubview(editBtnCancel)
        editStackView.addArrangedSubview(editLabel)
        editStackView.addArrangedSubview(editComplete)
        
        effectStackView.addArrangedSubview(effectBtnCancel)
        effectStackView.addArrangedSubview(effectLabel)
        effectStackView.addArrangedSubview(effectComplete)
        
        effectStackView.isHidden = true
        
        headerStackView.addSubview(editStackView)
        headerStackView.addSubview(effectStackView)
        
        NSLayoutConstraint.activate([
            editStackView.topAnchor.constraint(equalTo: headerStackView.topAnchor),
            editStackView.leadingAnchor.constraint(equalTo: headerStackView.leadingAnchor, constant: 16),
            editStackView.trailingAnchor.constraint(equalTo: headerStackView.trailingAnchor, constant: -16),
            editStackView.heightAnchor.constraint(equalTo: headerStackView.heightAnchor),
            
            effectStackView.topAnchor.constraint(equalTo: editStackView.topAnchor),
            effectStackView.leadingAnchor.constraint(equalTo: editStackView.leadingAnchor),
            effectStackView.trailingAnchor.constraint(equalTo: editStackView.trailingAnchor),
            effectStackView.heightAnchor.constraint(equalTo: editStackView.heightAnchor)
        ])
    }
    
    private func setupToolActions() {
        
        // Tool slider chung
        photoToolSlider?.onSizeSelected = { [weak self] index in
            self?.getTool(index)
        }
        
        // Tool Filter
        filterView?.didSelectFilter = { [weak self] filterInfo, filteredImage in
            guard let self = self,
                  let originalImage = self.currentImage else { return }
            DispatchQueue.global(qos: .userInitiated).async {
                let fixedImage = UIImage(
                    cgImage: filteredImage.cgImage!,
                    scale: filteredImage.scale,
                    orientation: originalImage.imageOrientation
                )
                DispatchQueue.main.async {
                    self.containerImageView.setImage(fixedImage)
                }
            }
        }
        
        effectView?.didSelectFilter = { [weak self] filterInfo, filteredImage in
            guard let self = self,
                  let originalImage = self.currentImage else { return }
            DispatchQueue.global(qos: .userInitiated).async {
                let fixedImage = UIImage(
                    cgImage: filteredImage.cgImage!,
                    scale: filteredImage.scale,
                    orientation: originalImage.imageOrientation
                )
                DispatchQueue.main.async {
                    self.containerImageView.setImage(fixedImage)
                }
            }
        }
        
        adjustView.onImageUpdated = { [weak self] newImage in
            self?.containerImageView.setImage(newImage)
        }
        
        drawingToolView.onColorSlieChanged = { [weak drawingLayer] color in
            drawingLayer?.brushColor = color
        }
        
        drawingToolView.onSizeChanged = { [weak drawingLayer] size in
            drawingLayer?.brushSize = size
        }
        
        drawingToolView.iseraserEnable = { [weak drawingLayer] in
            drawingLayer?.isErasing = !drawingLayer!.isErasing
        }
        
        curvesAdjustmentView.onCurveChanged = { [weak self] points in
            guard let self = self else { return }
            let lut = generateLUT(from: points)
            if let newImage = self.currentImage?.applyingLUT(lut) {
                containerImageView.setImage(newImage)
            }
        }
        emojiSliderView.onEmojiSelected = { [weak containerImageView] emoji in
            let editable = EditableView(frame: CGRect(x: 50, y: 50, width: 120, height: 120), emoji: emoji)
            containerImageView?.imageView.addSubview(editable)
        }
        
        stickerSliderView.onEmojiSelected = { [weak containerImageView] index in
            let editable = StickerEditableView(frame: CGRect(x: 50, y: 50, width: 120, height: 120), imageIndex: index)
            containerImageView?.imageView.addSubview(editable)
        }
    }
    
    // MARK: - Public Methods
    func setImageEdit(_ imageEdit: ImageEdited) {
        self.currentImageEdit = imageEdit
        self.currentImage = imageEdit.imageEdited
        // Hiển thị ảnh gốc
        containerImageView.setImage(self.currentImage)
        containerImageView.isZoomEnabled = true
        containerImageView.maximumZoomScale = 4.0
        
        if let image = currentImage {
            focusImageView = FocusImageView(frame: containerImageView.bounds, image: image, initialRadius: 100)
            focusImageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            //            addSubview(focusImageView)
            focusImageView.isHidden = true
            containerImageView.addSubview(focusImageView) // Gắn spotlight lên ảnh
        }
        
        drawingLayerColorDetele = DrawingDeleteColorImageView(frame: containerImageView.imageView.bounds, baseImage: imageEdit.imageEdited)
        containerImageView.imageView.addSubview(drawingLayerColorDetele!)
        containerImageView.imageView.isUserInteractionEnabled = true
        drawingLayerColorDetele?.isUserInteractionEnabled = true
        drawingLayerColorDetele?.isHidden = true
        
        drawingDeleteColorView.iseraserEnable = { [weak drawingLayerColorDetele] in
            drawingLayerColorDetele?.isErasing = !drawingLayerColorDetele!.isErasing
        }
        drawingDeleteColorView.onSizeChanged = { [weak drawingLayerColorDetele] size in
            drawingLayerColorDetele?.brushSize = size
        }
        
        // Truyền ảnh gốc cho filter
        filterView?.originalImage = imageEdit.imageEdited
        effectView?.originalImage = imageEdit.imageEdited
    }
    
    private func getTool(_ type: Int) {
        collectionViewTool.isHidden = true
        editStackView.isHidden = true
        effectStackView.isHidden = false
        
        switch type {
        case 1:
            collectionViewFilter.isHidden = false
            effectLabel.text = photoEditToolModel.listTool[type - 1].name
            currentCollectionView = collectionViewFilter
        case 2:
            barBottomTool.isHidden = true
            adjustView.isHidden = false
            effectLabel.text = photoEditToolModel.listTool[type - 1].name
            currentCollectionView = collectionViewFilter
            setupAdjustView()
        case 3:
            collectionViewEffect.isHidden = false
            effectLabel.text = photoEditToolModel.listTool[type - 1].name
            currentCollectionView = collectionViewEffect
        case 4:
            toggleSpotlight()
            effectLabel.text = photoEditToolModel.listTool[type - 1].name
            currentCollectionView = collectionViewEffect
            focusImageView.isHidden = false
        case 5:
            stackFlip.isHidden = false
            currentCollectionView = collectionViewFilter
            effectLabel.text = photoEditToolModel.listTool[type - 1].name
        case 6:
            drawingToolView.isHidden = false
            currentCollectionView = collectionViewFilter
            effectLabel.text = photoEditToolModel.listTool[type - 1].name
            containerImageView.isZoomEnabled = false
            drawingLayer.isHidden = false
        case 7:
            drawingDeleteColorView.isHidden = false
            currentCollectionView = collectionViewFilter
            effectLabel.text = photoEditToolModel.listTool[type - 1].name
            containerImageView.isZoomEnabled = false
            drawingLayerColorDetele?.isHidden = false
        case 8:
            curvesAdjustmentView.isHidden = false
            barBottomTool.isHidden = true
            currentCollectionView = collectionViewFilter
            effectLabel.text = photoEditToolModel.listTool[type - 1].name
        case 9:
            currentCollectionView = collectionViewFilter
            effectLabel.text = photoEditToolModel.listTool[type - 1].name
            emojiSliderView.isHidden = false
        case 10:
            currentCollectionView = collectionViewFilter
            effectLabel.text = photoEditToolModel.listTool[type - 1].name
            stickerSliderView.isHidden = false
        case 11:
            currentCollectionView = collectionViewFilter
            effectLabel.text = photoEditToolModel.listTool[type - 1].name
            textToolBarView.isHidden = false
        default:
            break
        }
    }
    
    @objc private func backView(){
        collectionViewTool.isHidden = false
        barBottomTool.isHidden = false
        editStackView.isHidden = false
        adjustView.isHidden = true
        effectStackView.isHidden = true
        currentCollectionView!.isHidden = true
        containerImageView.setImage(self.currentImage)
        stackFlip.isHidden = true
        drawingToolView.isHidden = true
        focusImageView.isHidden = true
        containerImageView.isZoomEnabled = true
        drawingLayer.isHidden = true
        drawingDeleteColorView.isHidden = true
        drawingLayerColorDetele?.isHidden = true
        curvesAdjustmentView.isHidden = true
        emojiSliderView.isHidden = true
        stickerSliderView.isHidden = true
        removeEmoji()
        removeSticker()
        textToolBarView.isHidden = true

    }
    
    @objc private func closeTapped() {
        closeView?()
    }
    
    private func setupAdjustView(){
        if let image = currentImage {
            containerImageView.setImage(image)
            adjustView.setImage(image)
        }
    }
    
    private func removeEmoji(){
        for subview in containerImageView.imageView.subviews {
            if subview is EditableView {
                subview.removeFromSuperview()
            }
        }
    }
    
    private func removeSticker(){
        for subview in containerImageView.imageView.subviews {
            if subview is StickerEditableView {
                subview.removeFromSuperview()
            }
        }
    }
    func toggleSpotlight() {
        
    }
    
    @objc func flipH() {
        containerImageView.flipHorizontal()
    }
    
    @objc func flipV() {
        containerImageView.flipVertical()
    }
}


