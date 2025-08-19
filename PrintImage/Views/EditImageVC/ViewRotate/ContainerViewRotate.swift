//
//  ContainerViewRotate.swift
//  PrintImage
//
//  Created by Alex Tran on 5/8/25.
//

import UIKit

class ContainerViewRotate: UIView {
    
    private let mediaSelectStackView = MediaSelectStackView()
    private let collectionViewSize = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private var sliderhandler: CollectionViewSlider?
    private let unitStackView = UnitStackView()
    private let imageInfoControllerView = ImageInfoControlView()
    private let containerImageView = UIView()
    private let bottomBarView = BottomBarView()
    private let viewRotateModel = ViewRotateModel()
    private let imageFrame = ZoomableImageView()
    private var didLayoutOnce = false
    private var images : [UIImage] = []
    private var arrSizeChoice : [Int] = [3,1,6]
    private var typeTocChangeFrame : Int = 0
    private var isSwarpImage : Bool = false
    private var numberImage : Int = 0
   
    
    var closeEditImage: (() -> Void)?
    var addImageToData: ((_ imageEdit: ImageEdited) -> Void)?
    var openColorPickerView: (() -> Void)?
    var openPhotoTool: ((_ image: ImageEdited) -> Void)?
    var imageEdit : ImageEdited?
    
    
    private var rotateImage : CGAffineTransform = CGAffineTransform(rotationAngle: 0) {
        didSet {
            imageEdit?.imageEdited = currentImageEdit.applying(transform: rotateImage) ?? currentImageEdit
        }
    }
    
    var imageBacground : String = "#ffffff" {
        didSet {
            imageEdit?.backgroundColor = imageBacground
            imageFrame.backgroundColor = UIColor(hexString: imageBacground)
        }
    }
    
    private var currentTypePaper : Int = 1 {
        didSet {
            imageEdit?.typePaper = currentTypePaper
        }
    }
    
    private var currentImageEdit : UIImage = UIImage() {
        didSet {
            updateImageViewFrameIfNeeded()
            imageEdit?.imageOrigin = currentImageEdit
        }
    }
    
    private var currentSize : (width:CGFloat,height:CGFloat) = (0,0) {
        didSet {
            imageInfoControllerView.currentSize = currentSize
            imageEdit?.width = currentSize.width
            imageEdit?.height = currentSize.height
            
        }
    }
    private var currentTypeSize: Int = 2 {
        didSet {
            imageInfoControllerView.currentTypeSize = currentTypeSize
            unitStackView.currentTypeSize = currentTypeSize
            imageEdit?.typeSize = currentTypeSize
        }
    }
    
    
    init(images:[UIImage]){
        self.images = images
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if !didLayoutOnce {
            didLayoutOnce = true
            setupLayout()
            bottomBarView.currentNumerImage = (1,images.count)
            DispatchQueue.main.async { [weak self] in
                self?.updateImageViewFrameIfNeeded()
                self?.handleSelectCell(0)
            }
        }
    }
    
    private func setup(){
        
        // MARK: - self
        self.backgroundColor = .clear
        self.translatesAutoresizingMaskIntoConstraints = false
        
        
        
        // MARK: - layout in collectionview
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 2
        collectionViewSize.collectionViewLayout = layout
        collectionViewSize.backgroundColor = .clear
        collectionViewSize.translatesAutoresizingMaskIntoConstraints = false
        sliderhandler = CollectionViewSlider(collectionView: collectionViewSize)
        sliderhandler?.currentImage = (images[0].size.width , images[0].size.height)
        sliderhandler?.onSizeSelected = { [weak self] selectedValue in
            self?.handleSelectedValue(selectedValue)
        }
        
        
        // MARK: - container image view
        containerImageView.backgroundColor = .clear
        containerImageView.translatesAutoresizingMaskIntoConstraints = false
        containerImageView.addSubview(imageFrame)
        
        // MARK: - add subview
        addSubview(mediaSelectStackView)
        addSubview(collectionViewSize)
        addSubview(unitStackView)
        addSubview(imageInfoControllerView)
        addSubview(containerImageView)
        addSubview(bottomBarView)
        
        // MARK: - func setup
        setupAction()
        imageAssignment()
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            mediaSelectStackView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0),
            mediaSelectStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            mediaSelectStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            
            collectionViewSize.topAnchor.constraint(equalTo: mediaSelectStackView.bottomAnchor, constant: 2),
            collectionViewSize.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0),
            collectionViewSize.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0),
            collectionViewSize.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.08),
            
            unitStackView.topAnchor.constraint(equalTo: collectionViewSize.bottomAnchor, constant: 2),
            unitStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0),
            unitStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0),
            unitStackView.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.03),
            
            imageInfoControllerView.topAnchor.constraint(equalTo: unitStackView.bottomAnchor, constant: 2),
            imageInfoControllerView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0),
            imageInfoControllerView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0),
            imageInfoControllerView.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.08),
            
            containerImageView.topAnchor.constraint(equalTo: imageInfoControllerView.bottomAnchor, constant: 2),
            containerImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0),
            containerImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0),
            
            bottomBarView.topAnchor.constraint(equalTo: containerImageView.bottomAnchor, constant: 0),
            bottomBarView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0),
            bottomBarView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            bottomBarView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            bottomBarView.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.08),
            
        ])
    }
    
    private func imageAssignment(){
        guard !images.isEmpty else {
            return
        }
        currentImageEdit = images[0]
    }
    
    private func setupAction(){
        mediaSelectStackView.onGridTapped = { [weak self] isgridVisible in
            self?.imageFrame.setGridVisible(!isgridVisible)
        }
        
        mediaSelectStackView.onPaletteTapped = { [weak self] in
            self?.openColorPickerView?()
        }
        
        mediaSelectStackView.onSliderTapped = { [weak self] in
            self?.openPhotoTool?(self!.imageEdit!)
        }
        
        imageInfoControllerView.onSwap = { [weak self] in
            self?.swapWidthAndHeight()
        }
        
        imageInfoControllerView.onRotateRight = { [weak self] in
            self?.rotateImageDegree()
        }
        
        imageInfoControllerView.onRotateLeft = { [weak self] in
            self?.rotateImageIngree()
        }
        
        unitStackView.onUnitTapped = { [weak self] type in
            self?.handleUnit(type)
        }
        
        bottomBarView.onClose = { [weak self] in
            self?.handleCloseEditVc()
            
        }
        
        bottomBarView.onNextImage = { [weak self] in
            self?.handleNextImage()
            
        }
        
        imageFrame.passRotate = { [weak self] value in
            self?.rotateImage = value
        }
    }
    
    private func updateImageViewFrameIfNeeded() {
        guard containerImageView.bounds.width > 0, containerImageView.bounds.height > 0 else {
            return
        }
        let width = currentImageEdit.size.width
        let height = currentImageEdit.size.height
        let newSize = viewRotateModel.changeSizehandler(with: 1, currentImage: (width,height), in: containerImageView)
        imageFrame.frame.size = newSize.size
        imageFrame.center = CGPoint(x: containerImageView.bounds.midX, y: containerImageView.bounds.midY)
        imageFrame.setImage(currentImageEdit,sizeImage: newSize.size)
        currentSize = newSize.frameSize
        currentTypeSize = newSize.typeSize
        arrSizeChoice = [3,1,6]
        imageEdit = ImageEdited(width: newSize.frameSize.width, height: newSize.frameSize.height, imageOrigin: currentImageEdit, imageEdited: currentImageEdit, typeSize: newSize.typeSize, typePaper: 1)
        self.hideLoading()
    }
    
    private func handleSelectedValue(_ type: Int) {
        let width = currentImageEdit.size.width
        let height = currentImageEdit.size.height
        let newSize = viewRotateModel.changeSizehandler(with: type, currentImage: (width,height), in: containerImageView)
        imageFrame.frame.size = newSize.size
        imageFrame.center = CGPoint(x: containerImageView.bounds.midX, y: containerImageView.bounds.midY)
        imageFrame.setImage(currentImageEdit,sizeImage: newSize.size)
        currentSize = newSize.frameSize
        currentTypeSize = newSize.typeSize
        arrSizeChoice = viewRotateModel.createArraySize(type,oldArr: arrSizeChoice)
        typeTocChangeFrame = type
        isSwarpImage = false
        currentTypePaper = type
    }
    
    private func handleSelectCell(_ index:Int) {
        let indexPath = IndexPath(item: index, section: 0)
        self.collectionViewSize.selectItem(at: indexPath, animated: false, scrollPosition: [])
        self.collectionViewSize.delegate?.collectionView?(self.collectionViewSize, didSelectItemAt: indexPath)
    }
    
    private func swapWidthAndHeight(){
        isSwarpImage = !isSwarpImage
        let width = currentSize.height
        let height = currentSize.width
        currentSize = (width,height)
        
        let widthFrame = currentImageEdit.size.width
        let heightFame = currentImageEdit.size.height
        
        if(isSwarpImage){
            let newSize = viewRotateModel.changeSizehandlerSwap(with: typeTocChangeFrame, currentImage: (widthFrame,heightFame), in: containerImageView)
            imageFrame.frame.size = newSize
            imageFrame.center = CGPoint(x: containerImageView.bounds.midX, y: containerImageView.bounds.midY)
            imageFrame.setImage(currentImageEdit,sizeImage: newSize)
        } else {
            let newSize = viewRotateModel.changeSizehandler(with: typeTocChangeFrame, currentImage: (widthFrame,heightFame), in: containerImageView)
            imageFrame.frame.size = newSize.size
            imageFrame.center = CGPoint(x: containerImageView.bounds.midX, y: containerImageView.bounds.midY)
            imageFrame.setImage(currentImageEdit,sizeImage: newSize.size)
        }
        
    }
    
    private func rotateImageDegree() {
        imageFrame.rotateImageBy90Degrees()
    }
    
    private func rotateImageIngree() {
        imageFrame.rotateImageBy90Ingrees()
    }
    
    private func handleUnit(_ type:Int) {
        switch type {
        case 0:
            handleSelectedValue(arrSizeChoice[0])
            handleSelectCell(arrSizeChoice[0]-1)
        case 1:
            handleSelectedValue(arrSizeChoice[1])
            handleSelectCell(arrSizeChoice[1]-1)
        case 2:
            handleSelectedValue(arrSizeChoice[2])
            handleSelectCell(arrSizeChoice[2]-1)
        default:
            break
        }
    }
    
    private func handleNextImage(){
        if(images.count == 1) {
            let imageCrop = imageFrame.renderViewToImage()
            imageEdit?.imageEdited = imageCrop
            addImageToData?(imageEdit!)
        } else {
            numberImage += 1
            if((numberImage + 1) > images.count) {
                print(numberImage)
            } else {
                let imageCrop = imageFrame.cropVisibleImage()
                imageEdit!.imageEdited = imageCrop ?? currentImageEdit
                addImageToData?(imageEdit!)
                bottomBarView.currentNumerImage = (numberImage + 1,images.count)
                currentImageEdit = images [numberImage]
            }
        }
        
        
       
        
    }
    
    private func handleCloseEditVc(){
        closeEditImage?()
    }
}
