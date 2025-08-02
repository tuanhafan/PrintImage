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
    private var currentImageEdit : UIImage = UIImage() {
        didSet {
            let width = currentImageEdit.size.width
            let height = currentImageEdit.size.height
            imageFrame.setImage(currentImageEdit)
            imageFrame.heightAnchor.constraint(equalToConstant: height*0.1).isActive = true
            imageFrame.widthAnchor.constraint(equalToConstant: width*0.1).isActive = true
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
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
        let squareshapeBtn = ButtonIcon.createIconButton(systemName: "squareshape.split.3x3")
        squareshapeBtn.tintColor = .lightGray
        let sliderBntn = ButtonIcon.createIconButton(systemName: "slider.horizontal.3")
        
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
        
        [mmLabel,cmLabel,inchLabel].forEach{
            $0.font = UIFont.systemFont(ofSize: 14, weight: .medium)
            $0.textColor = .white
            $0.backgroundColor = .darkGray
            $0.textAlignment = .center
            $0.translatesAutoresizingMaskIntoConstraints = false
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
        
        let topStv = UIStackView()
        let mainStv = UIStackView()
        let labelSmaller = UILabel()
        let centerStv = UIStackView()
        let btnRotateLeft = ButtonIcon.createIconButton(systemName: "arrowshape.turn.up.left.fill")
        let btnRotateRight = ButtonIcon.createIconButton(systemName: "arrowshape.turn.up.right.fill")
        let btnChangeTypeSize = UIButton()
        let btnSwap = UIButton()
        let widthLabel = UILabel()
        let heightLabel = UILabel()
        let widthTf = UITextField()
        let heighttf = UITextField()
        
        
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
        btnSwap.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 24, weight: .bold), forImageIn: .normal)
        btnSwap.tintColor = .white
        
        centerStv.addArrangedSubview(widthTf)
        centerStv.addArrangedSubview(btnChangeTypeSize)
        centerStv.addArrangedSubview(heighttf)
        
        mainStv.addArrangedSubview(btnRotateLeft)
        mainStv.addArrangedSubview(centerStv)
        mainStv.addArrangedSubview(btnRotateRight)
        
        topStv.addArrangedSubview(widthLabel)
        topStv.addArrangedSubview(btnSwap)
        topStv.addArrangedSubview(heightLabel)
        
        centerStv.axis = .horizontal
        centerStv.spacing = 10
        
        topStv.axis = .horizontal
        topStv.alignment = .bottom
        topStv.spacing = 10
        topStv.distribution = .equalSpacing
        topStv.translatesAutoresizingMaskIntoConstraints = false
        
        mainStv.axis = .horizontal
        mainStv.distribution = .equalSpacing
        mainStv.alignment = .bottom
        mainStv.spacing = 8
        mainStv.translatesAutoresizingMaskIntoConstraints = false
        
        labelSmaller.text = "≤ 40 ml"
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
        viewRotate.addSubview(topStv)
        viewRotate.addSubview(mainStv)
        viewRotate.addSubview(labelSmaller)
        
        NSLayoutConstraint.activate([
            
            topStv.topAnchor.constraint(equalTo: viewRotate.topAnchor, constant: 3),
            topStv.leadingAnchor.constraint(equalTo: viewRotate.leadingAnchor, constant: 100),
            topStv.trailingAnchor.constraint(equalTo: viewRotate.trailingAnchor, constant: -100),
            topStv.heightAnchor.constraint(equalTo: viewRotate.heightAnchor, multiplier: 0.35),
            
            mainStv.topAnchor.constraint(equalTo: topStv.bottomAnchor, constant: 3),
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
        ])
        
    }
    
    private func setupContenViewImage() {
        contenViewImage.backgroundColor = .clear
        contenViewImage.translatesAutoresizingMaskIntoConstraints = false
        imageFrame.translatesAutoresizingMaskIntoConstraints = false
        contenViewImage.addSubview(imageFrame)
        	
        
        NSLayoutConstraint.activate([
            contenViewImage.topAnchor.constraint(equalTo: viewRotate.bottomAnchor, constant: 2),
            contenViewImage.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            contenViewImage.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            
            imageFrame.centerXAnchor.constraint(equalTo: contenViewImage.centerXAnchor),
            imageFrame.centerYAnchor.constraint(equalTo: contenViewImage.centerYAnchor),
           
        ])
    }
    
    private func setupBottomBar() {
        bottomBarView.backgroundColor = .darkGray
        bottomBarView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            bottomBarView.topAnchor.constraint(equalTo: contenViewImage.bottomAnchor, constant: 0),
            bottomBarView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),
            bottomBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomBarView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.06)
        ])
    }
    
    
}
