//
//  EditImageVC.swift
//  PrintImage
//
//  Created by Alex Tran on 21/7/25.
//

import UIKit

class EditImageVC: UIViewController {
    private let topBarView = UIView()
    private let mediaSelectView = UIStackView()
    private let bottomBarView = UIView()
    private let contenViewImage = UIView()
    private let collectionViewSize = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private var sliderhandler: CollectionViewSlider!
    private let typeSizeStv = UIStackView()
    private let viewRotate = UIView()
    private let imageFrame = ZoomableImageView()
    private let images: [UIImage]
    private let labelSmaller = UILabel()
    private let widthTf = UITextField()
    private let heighttf = UITextField()
    private let squareshapeBtn = ButtonIcon.createIconButton(systemName: "squareshape.split.3x3")
    private let editImageModel = EditImageModel()
    private var didLayoutOnce = false
    private var arrSizeChoice : [Int] = [3,1,6]
    private var typeTocChangeFrame : Int = 0
    private var isSwarpImage : Bool = false
    private var currentSize : (width:CGFloat,height:CGFloat) = (0,0) {
        didSet {
            widthTf.text = "\(currentSize.width)"
            heighttf.text = "\(currentSize.height)"
            
        }
    }
    
    private var currentTypeSize: Int = 2 {
        didSet {
            for (index, view) in typeSizeStv.arrangedSubviews.enumerated() {
                guard let label = view as? UILabel else { continue }
                if index  == currentTypeSize {
                    label.backgroundColor = .white
                    label.textColor = .black
                } else {
                    label.backgroundColor = .darkGray
                    label.textColor = .white
                }
            }
            
            switch currentTypeSize {
            case 0:
                labelSmaller.text = "≤ 1000 mm"
            case 1:
                labelSmaller.text = "≤ 100 cm"
            case 2:
                labelSmaller.text = "≤ 40 inch"
            default:
                labelSmaller.text = "≤ 100 cm"
            }
        }
    }
    private var currentImageEdit : UIImage = UIImage() {
        didSet {
            
        }
    }
    
    private var isgridVisible: Bool = false {
        didSet {
            imageFrame.setGridVisible(!isgridVisible)
            
        }
    }
    
    
    init(images: [UIImage]) {
        self.images = images
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .secondaryLabel
        
        
        addComponents()
        setupTopBar()
        setupMediaSelectBar()
        setupSlider()
        setuptypeSizeStv()
        setupViewRotate()
        setupContenViewImage()
        setupBottomBar()
        imageAssignment()
        sliderhandler = CollectionViewSlider(collectionView: collectionViewSize)
        sliderhandler.currentImage = (currentImageEdit.size.width , currentImageEdit.size.height)
        sliderhandler.onSizeSelected = { [weak self] selectedValue in
            self?.handleSelectedValue(selectedValue)
        }
        
        DispatchQueue.main.async {
            self.handleSelectCell(0)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !didLayoutOnce {
                updateImageViewFrameIfNeeded()
                didLayoutOnce = true
            }
        
    }
    private func updateImageViewFrameIfNeeded() {
        
        // Kiểm tra kích thước hợp lệ
        guard contenViewImage.bounds.width > 0, contenViewImage.bounds.height > 0 else {
            return
        }
        let width = currentImageEdit.size.width
        let height = currentImageEdit.size.height
        let newSize = editImageModel.changeSizehandler(with: 1, currentImage: (width,height), in: contenViewImage)
        imageFrame.frame.size = newSize.size
        imageFrame.center = CGPoint(x: contenViewImage.bounds.midX, y: contenViewImage.bounds.midY)
        imageFrame.setImage(currentImageEdit,sizeImage: newSize.size)
        currentSize = newSize.frameSize
        currentTypeSize = newSize.typeSize
        arrSizeChoice = [3,1,6]
    }
    
    private func addComponents() {
        view.addSubview(topBarView)
        view.addSubview(mediaSelectView)
        view.addSubview(collectionViewSize)
        view.addSubview(typeSizeStv)
        view.addSubview(viewRotate)
        view.addSubview(contenViewImage)
        view.addSubview(bottomBarView)
    }
    
    private func imageAssignment(){
        guard !images.isEmpty else {
            return
        }
        currentImageEdit = images[0]
    }
    
    
    private func handleSelectedValue(_ type: Int) {
        let width = currentImageEdit.size.width
        let height = currentImageEdit.size.height
        let newSize = editImageModel.changeSizehandler(with: type, currentImage: (width,height), in: contenViewImage)
        imageFrame.frame.size = newSize.size
        imageFrame.center = CGPoint(x: contenViewImage.bounds.midX, y: contenViewImage.bounds.midY)
        imageFrame.setImage(currentImageEdit,sizeImage: newSize.size)
        currentSize = newSize.frameSize
        currentTypeSize = newSize.typeSize
        arrSizeChoice = editImageModel.createArraySize(type,oldArr: arrSizeChoice)
        typeTocChangeFrame = type
        isSwarpImage = false
    }
    
    private func setupTopBar() {
        topBarView.backgroundColor = .darkGray
        topBarView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topBarView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            topBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topBarView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.07)
        ])
    }
    
    
    private func setupMediaSelectBar() {
        mediaSelectView.axis = .horizontal
        mediaSelectView.alignment = .center
        mediaSelectView.distribution = .equalSpacing
        mediaSelectView.spacing = ResponsiveLayout.bottomSpacing()
        mediaSelectView.translatesAutoresizingMaskIntoConstraints = false
        mediaSelectView.backgroundColor = UIColor.darkGray
        mediaSelectView.isLayoutMarginsRelativeArrangement = true
        mediaSelectView.layoutMargins = UIEdgeInsets(top: 5, left: ResponsiveLayout.horizontalMargin(), bottom: 5, right: ResponsiveLayout.horizontalMargin())
        
        // Add buttons
        let paintpaletteBtn = ButtonIcon.createIconButton(systemName: "paintpalette.fill")
        let sliderBntn = ButtonIcon.createIconButton(systemName: "slider.horizontal.3")
        squareshapeBtn.tintColor = .lightGray
        squareshapeBtn.addTarget(self, action: #selector(showGrid), for: .touchUpInside)
        [paintpaletteBtn, squareshapeBtn, sliderBntn].forEach { btn in
            btn.widthAnchor.constraint(equalToConstant: ResponsiveLayout.buttonSize()).isActive = true
            btn.heightAnchor.constraint(equalToConstant: ResponsiveLayout.buttonSize()).isActive = true
            mediaSelectView.addArrangedSubview(btn)
        }
        
        
        mediaSelectView.backgroundColor = .darkGray
        mediaSelectView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            mediaSelectView.topAnchor.constraint(equalTo: topBarView.bottomAnchor, constant: 2),
            mediaSelectView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mediaSelectView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
        ])
    }
    
    private func setupSlider() {
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 2
        collectionViewSize.collectionViewLayout = layout
        collectionViewSize.backgroundColor = .clear
        collectionViewSize.translatesAutoresizingMaskIntoConstraints = false
        
        
        NSLayoutConstraint.activate([
            collectionViewSize.topAnchor.constraint(equalTo: mediaSelectView.bottomAnchor, constant: 2),
            collectionViewSize.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            collectionViewSize.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            collectionViewSize.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.08)
        ])
    }
    
    private func setuptypeSizeStv() {
        
        let mmLabel = UILabel()
        let cmLabel = UILabel()
        let inchLabel = UILabel()
        let labels = [mmLabel, cmLabel, inchLabel]
        labels.enumerated().forEach { (index, label) in
            label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
            label.textColor = .white
            label.backgroundColor = .darkGray
            label.textAlignment = .center
            label.translatesAutoresizingMaskIntoConstraints = false
            
            label.isUserInteractionEnabled = true
            label.tag = index // Gán tag nếu muốn biết label nào được nhấn
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleLabelTap(_:)))
            label.addGestureRecognizer(tapGesture)
        }
        
        mmLabel.text = "mm"
        cmLabel.text = "cm"
        inchLabel.text = "inch"
        
        
        
        typeSizeStv.axis = .horizontal
        typeSizeStv.alignment = .center
        typeSizeStv.distribution = .fillEqually
        typeSizeStv.backgroundColor = UIColor.white
        typeSizeStv.spacing = 1
        typeSizeStv.translatesAutoresizingMaskIntoConstraints = false
        
        
        typeSizeStv.addArrangedSubview(mmLabel)
        typeSizeStv.addArrangedSubview(cmLabel)
        typeSizeStv.addArrangedSubview(inchLabel)
        
        NSLayoutConstraint.activate([
            typeSizeStv.topAnchor.constraint(equalTo: collectionViewSize.bottomAnchor, constant: 2),
            typeSizeStv.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            typeSizeStv.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            typeSizeStv.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.03)
        ])
        typeSizeStv.superview?.layoutIfNeeded()
        
        
        [mmLabel,cmLabel,inchLabel].forEach{
            $0.topAnchor.constraint(equalTo: typeSizeStv.topAnchor, constant: 1).isActive = true
            $0.bottomAnchor.constraint(equalTo: typeSizeStv.bottomAnchor, constant: -1).isActive = true
        }
    }
    
    private func setupViewRotate(){
        viewRotate.translatesAutoresizingMaskIntoConstraints = false
        viewRotate.backgroundColor = .darkGray
        
        let mainStv = UIStackView()
        let centerStv = UIStackView()
        let btnRotateLeft = ButtonIcon.createIconButton(systemName: "arrowshape.turn.up.left.fill")
        let btnRotateRight = ButtonIcon.createIconButton(systemName: "arrowshape.turn.up.right.fill")
        let btnChangeTypeSize = UIButton()
        let btnSwap = UIButton()
        let widthLabel = UILabel()
        let heightLabel = UILabel()
        let widthView = UIView()
        let heightView = UIView()
        
        btnRotateLeft.addTarget(self, action: #selector(rotateImageIngree), for: .touchUpInside)
        btnRotateRight.addTarget(self, action: #selector(rotateImageDegree), for: .touchUpInside)
        
        
        widthTf.text = "3.5"
        heighttf.text = "4.67"
        widthLabel.text = "Chiều rộng"
        heightLabel.text = "Chiều cao"
        
        
        [widthTf,heighttf].forEach{
            $0.backgroundColor = .white
            $0.textColor = .black
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.textAlignment = .center
            $0.layer.cornerRadius = 3
            $0.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        }
        
        [widthLabel,heightLabel].forEach{
            $0.textColor = .white
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.textAlignment = .center
            $0.font = UIFont.systemFont(ofSize: 12, weight: .thin)
        }
        
        
        widthTf.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        heighttf.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        btnChangeTypeSize.setImage(UIImage(systemName: "arrow.trianglehead.topright.capsulepath.clockwise"), for: .normal)
        btnChangeTypeSize.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 14, weight: .bold), forImageIn: .normal)
        btnChangeTypeSize.transform = CGAffineTransform(rotationAngle: .pi / 2)
        btnChangeTypeSize.tintColor = .white
        
        btnSwap.setImage(UIImage(systemName: "arrow.trianglehead.2.clockwise"), for: .normal)
        btnSwap.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 18, weight: .bold), forImageIn: .normal)
        btnSwap.tintColor = .white
        btnSwap.addTarget(self, action: #selector(swapWidthAndHeight), for: .touchUpInside)
        
        [widthView,heightView].forEach{
            $0.backgroundColor = .clear
            //            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        widthView.addSubview(widthLabel)
        widthView.addSubview(widthTf)
        heightView.addSubview(heightLabel)
        heightView.addSubview(heighttf)
        
        centerStv.addArrangedSubview(widthView)
        centerStv.addArrangedSubview(btnSwap)
        centerStv.addArrangedSubview(heightView)
        
        mainStv.addArrangedSubview(btnRotateLeft)
        mainStv.addArrangedSubview(centerStv)
        mainStv.addArrangedSubview(btnRotateRight)
        
        
        centerStv.axis = .horizontal
        centerStv.spacing = 15
        centerStv.alignment = .bottom
        
        mainStv.axis = .horizontal
        mainStv.distribution = .equalSpacing
        mainStv.alignment = .bottom
        mainStv.spacing = 8
        mainStv.translatesAutoresizingMaskIntoConstraints = false
        
        labelSmaller.text = "≤ 100 cm"
        labelSmaller.textAlignment = .center
        labelSmaller.font = UIFont.systemFont(ofSize: 10, weight: .medium)
        labelSmaller.textColor = .white
        labelSmaller.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            viewRotate.topAnchor.constraint(equalTo: typeSizeStv.bottomAnchor, constant: 2),
            viewRotate.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            viewRotate.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            viewRotate.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.08),
        ])
        
        viewRotate.superview?.layoutIfNeeded()
        viewRotate.addSubview(mainStv)
        viewRotate.addSubview(labelSmaller)
        
        NSLayoutConstraint.activate([
            
            
            
            mainStv.topAnchor.constraint(equalTo: viewRotate.topAnchor, constant: 10),
            mainStv.leadingAnchor.constraint(equalTo: viewRotate.leadingAnchor, constant: 20),
            mainStv.trailingAnchor.constraint(equalTo: viewRotate.trailingAnchor, constant: -20),
            mainStv.bottomAnchor.constraint(equalTo: labelSmaller.topAnchor, constant: -1),
            
            centerStv.heightAnchor.constraint(equalTo: mainStv.heightAnchor),
            
            widthTf.widthAnchor.constraint(equalToConstant: 100),
            heighttf.widthAnchor.constraint(equalToConstant: 100),
            
            
            labelSmaller.trailingAnchor.constraint(equalTo: viewRotate.trailingAnchor),
            labelSmaller.leadingAnchor.constraint(equalTo: viewRotate.leadingAnchor),
            labelSmaller.bottomAnchor.constraint(equalTo: viewRotate.bottomAnchor,constant: -2),
            labelSmaller.heightAnchor.constraint(equalTo: viewRotate.heightAnchor, multiplier: 0.25),
            
            
            widthLabel.topAnchor.constraint(equalTo: widthView.topAnchor, constant: 0),
            widthLabel.leadingAnchor.constraint(equalTo: widthView.leadingAnchor, constant: 0),
            widthLabel.trailingAnchor.constraint(equalTo: widthView.trailingAnchor, constant: 0),
            
            widthTf.topAnchor.constraint(equalTo: widthLabel.bottomAnchor, constant: 2),
            widthTf.leadingAnchor.constraint(equalTo: widthView.leadingAnchor, constant: 0),
            widthTf.trailingAnchor.constraint(equalTo: widthView.trailingAnchor, constant: 0),
            widthTf.bottomAnchor.constraint(equalTo: widthView.bottomAnchor, constant: 0),
            widthTf.heightAnchor.constraint(equalTo: widthView.heightAnchor, multiplier: 0.6),
            
            heightLabel.topAnchor.constraint(equalTo: heightView.topAnchor, constant: 0),
            heightLabel.leadingAnchor.constraint(equalTo: heightView.leadingAnchor, constant: 0),
            heightLabel.trailingAnchor.constraint(equalTo: heightView.trailingAnchor, constant: 0),
            
            heighttf.topAnchor.constraint(equalTo: heightLabel.bottomAnchor, constant: 2),
            heighttf.leadingAnchor.constraint(equalTo: heightView.leadingAnchor, constant: 0),
            heighttf.trailingAnchor.constraint(equalTo: heightView.trailingAnchor, constant: 0),
            heighttf.bottomAnchor.constraint(equalTo: heightView.bottomAnchor, constant: 0),
            heighttf.heightAnchor.constraint(equalTo: heightView.heightAnchor, multiplier: 0.6),
        ])
        
    }
    
    private func setupContenViewImage() {
        contenViewImage.backgroundColor = .clear
        contenViewImage.translatesAutoresizingMaskIntoConstraints = false
        contenViewImage.addSubview(imageFrame)
        
        
        NSLayoutConstraint.activate([
            contenViewImage.topAnchor.constraint(equalTo: viewRotate.bottomAnchor, constant: 2),
            contenViewImage.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            contenViewImage.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            
        ])
    }
    
    private func setupBottomBar() {
        bottomBarView.backgroundColor = .darkGray
        bottomBarView.translatesAutoresizingMaskIntoConstraints = false
        
        let subStackView = UIStackView()
        subStackView.axis = .horizontal
        subStackView.distribution = .equalSpacing
        subStackView.alignment = .center
        subStackView.translatesAutoresizingMaskIntoConstraints = false
        subStackView.isLayoutMarginsRelativeArrangement = true
        subStackView.layoutMargins = UIEdgeInsets(top: 5, left: ResponsiveLayout.horizontalMargin(), bottom: 5, right: ResponsiveLayout.horizontalMargin())
        
        
        let labelCount = UILabel()
        labelCount.text = "1 / 2"
        labelCount.textColor = .white
        labelCount.font = UIFont.systemFont(ofSize: 18)
        let closeBtn = ButtonIcon.createIconButton(systemName: "xmark")
        let checkmarkBtn = ButtonIcon.createIconButton(systemName: "checkmark")
        checkmarkBtn.tintColor = .systemBlue
        
        subStackView.addArrangedSubview(closeBtn)
        subStackView.addArrangedSubview(labelCount)
        subStackView.addArrangedSubview(checkmarkBtn)
        
        bottomBarView.addSubview(subStackView)
        
        
        NSLayoutConstraint.activate([
            bottomBarView.topAnchor.constraint(equalTo: contenViewImage.bottomAnchor, constant: 0),
            bottomBarView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),
            bottomBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomBarView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.08),
            
            subStackView.topAnchor.constraint(equalTo: bottomBarView.topAnchor, constant: 5),
            subStackView.leadingAnchor.constraint(equalTo: bottomBarView.leadingAnchor),
            subStackView.trailingAnchor.constraint(equalTo: bottomBarView.trailingAnchor),
        ])
    }
    
    @objc func showGrid(){
        isgridVisible = !isgridVisible
        squareshapeBtn.tintColor = isgridVisible ? .white : .lightGray
    }
    
    @objc func rotateImageDegree() {
        imageFrame.rotateImageBy90Degrees()
    }
    
    @objc func rotateImageIngree() {
        imageFrame.rotateImageBy90Ingrees()
    }
    
    @objc func handleLabelTap(_ gesture: UITapGestureRecognizer) {
        guard let tappedLabel = gesture.view as? UILabel else { return }
        currentTypeSize = tappedLabel.tag
       
        switch tappedLabel.tag {
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
    
    func handleSelectCell(_ index:Int) {
        let indexPath = IndexPath(item: index, section: 0)
        self.collectionViewSize.selectItem(at: indexPath, animated: false, scrollPosition: [])
        self.collectionViewSize.delegate?.collectionView?(self.collectionViewSize, didSelectItemAt: indexPath)
    }
    
    @objc func swapWidthAndHeight(){
        isSwarpImage = !isSwarpImage
        let width = currentSize.height
        let height = currentSize.width
        currentSize = (width,height)
        
        let widthFrame = currentImageEdit.size.width
        let heightFame = currentImageEdit.size.height
        
        if(isSwarpImage){
            let newSize = editImageModel.changeSizehandlerSwap(with: typeTocChangeFrame, currentImage: (widthFrame,heightFame), in: contenViewImage)
            imageFrame.frame.size = newSize
            imageFrame.center = CGPoint(x: contenViewImage.bounds.midX, y: contenViewImage.bounds.midY)
            imageFrame.setImage(currentImageEdit,sizeImage: newSize)
        }else {
            let newSize = editImageModel.changeSizehandler(with: typeTocChangeFrame, currentImage: (widthFrame,heightFame), in: contenViewImage)
            imageFrame.frame.size = newSize.size
            imageFrame.center = CGPoint(x: contenViewImage.bounds.midX, y: contenViewImage.bounds.midY)
            imageFrame.setImage(currentImageEdit,sizeImage: newSize.size)
        }
        
    }
}
