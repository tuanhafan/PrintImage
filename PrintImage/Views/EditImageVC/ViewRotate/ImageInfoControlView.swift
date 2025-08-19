//
//  TopView.swift
//  PrintImage
//
//  Created by Alex Tran on 5/8/25.
//

import UIKit

class ImageInfoControlView: UIView {
    
    
    // MARK: - Public Elements
    private let widthTextField = UITextField()
    private let heightTextField = UITextField()
    private let labelSmaller = UILabel()
    
    var onRotateLeft: (() -> Void)?
    var onRotateRight: (() -> Void)?
    var onSwap: (() -> Void)?
    
    
     var currentTypeSize: Int = 2 {
        didSet {
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
    
    var currentSize : (width:CGFloat,height:CGFloat) = (0,0) {
        didSet {
            widthTextField.text = "\(currentSize.width)"
            heightTextField.text = "\(currentSize.height)"
        }
    }
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    
    
    // MARK: - Setup UI
    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .darkGray
        
        let mainStack = UIStackView()
        let centerStack = UIStackView()
        
        let rotateLeftBtn = ButtonIcon.createIconButton(systemName: "arrowshape.turn.up.left.fill")
        let rotateRightBtn = ButtonIcon.createIconButton(systemName: "arrowshape.turn.up.right.fill")
        let swapBtn = UIButton()
        let changeTypeSizeBtn = UIButton()
        
        let widthLabel = UILabel()
        let heightLabel = UILabel()
        let widthContainer = UIView()
        let heightContainer = UIView()
        
        // Setup buttons
        rotateLeftBtn.addTarget(self, action: #selector(didTapRotateLeft), for: .touchUpInside)
        rotateRightBtn.addTarget(self, action: #selector(didTapRotateRight), for: .touchUpInside)
        
        swapBtn.setImage(UIImage(systemName: "arrow.trianglehead.2.clockwise"), for: .normal)
        swapBtn.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 18, weight: .bold), forImageIn: .normal)
        swapBtn.tintColor = .white
        swapBtn.addTarget(self, action: #selector(didTapSwap), for: .touchUpInside)
        
        changeTypeSizeBtn.setImage(UIImage(systemName: "arrow.trianglehead.topright.capsulepath.clockwise"), for: .normal)
        changeTypeSizeBtn.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 14, weight: .bold), forImageIn: .normal)
        changeTypeSizeBtn.transform = CGAffineTransform(rotationAngle: .pi / 2)
        changeTypeSizeBtn.tintColor = .white
        
        // Setup text fields
        widthTextField.text = "3.5"
        heightTextField.text = "4.67"
        
        [widthTextField, heightTextField].forEach {
            $0.backgroundColor = .white
            $0.textColor = .black
            $0.textAlignment = .center
            $0.layer.cornerRadius = 3
            $0.font = UIFont.systemFont(ofSize: 12, weight: .medium)
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        }
        
        // Setup labels
        widthLabel.text = "Chiều rộng"
        heightLabel.text = "Chiều cao"
        
        [widthLabel, heightLabel].forEach {
            $0.textColor = .white
            $0.textAlignment = .center
            $0.font = UIFont.systemFont(ofSize: 12, weight: .thin)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        labelSmaller.text = "≤ 100 cm"
        labelSmaller.textAlignment = .center
        labelSmaller.font = UIFont.systemFont(ofSize: 10, weight: .medium)
        labelSmaller.textColor = .white
        labelSmaller.translatesAutoresizingMaskIntoConstraints = false
        
        // Setup containers
        widthContainer.addSubview(widthLabel)
        widthContainer.addSubview(widthTextField)
        
        heightContainer.addSubview(heightLabel)
        heightContainer.addSubview(heightTextField)
        
        // Stack view setup
        centerStack.axis = .horizontal
        centerStack.spacing = 15
        centerStack.alignment = .bottom
        centerStack.addArrangedSubview(widthContainer)
        centerStack.addArrangedSubview(swapBtn)
        centerStack.addArrangedSubview(heightContainer)
        
        mainStack.axis = .horizontal
        mainStack.distribution = .equalSpacing
        mainStack.alignment = .bottom
        mainStack.spacing = 8
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        mainStack.addArrangedSubview(rotateLeftBtn)
        mainStack.addArrangedSubview(centerStack)
        mainStack.addArrangedSubview(rotateRightBtn)
        
        addSubview(mainStack)
        addSubview(labelSmaller)
        
        self.superview?.layoutIfNeeded()
        
        NSLayoutConstraint.activate([
            
            widthLabel.topAnchor.constraint(equalTo: widthContainer.topAnchor),
            widthLabel.leadingAnchor.constraint(equalTo: widthContainer.leadingAnchor),
            widthLabel.trailingAnchor.constraint(equalTo: widthContainer.trailingAnchor),
            
            widthTextField.topAnchor.constraint(equalTo: widthLabel.bottomAnchor, constant: 2),
            widthTextField.leadingAnchor.constraint(equalTo: widthContainer.leadingAnchor),
            widthTextField.trailingAnchor.constraint(equalTo: widthContainer.trailingAnchor),
            widthTextField.bottomAnchor.constraint(equalTo: widthContainer.bottomAnchor),
            widthTextField.heightAnchor.constraint(equalTo: widthContainer.heightAnchor, multiplier: 0.6),
            
            heightLabel.topAnchor.constraint(equalTo: heightContainer.topAnchor),
            heightLabel.leadingAnchor.constraint(equalTo: heightContainer.leadingAnchor),
            heightLabel.trailingAnchor.constraint(equalTo: heightContainer.trailingAnchor),
            
            heightTextField.topAnchor.constraint(equalTo: heightLabel.bottomAnchor, constant: 2),
            heightTextField.leadingAnchor.constraint(equalTo: heightContainer.leadingAnchor),
            heightTextField.trailingAnchor.constraint(equalTo: heightContainer.trailingAnchor),
            heightTextField.bottomAnchor.constraint(equalTo: heightContainer.bottomAnchor),
            heightTextField.heightAnchor.constraint(equalTo: heightContainer.heightAnchor, multiplier: 0.6),
            
            mainStack.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            mainStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            mainStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            mainStack.bottomAnchor.constraint(equalTo: labelSmaller.topAnchor, constant: -1),
            
            centerStack.heightAnchor.constraint(equalTo: mainStack.heightAnchor),
            
            widthTextField.widthAnchor.constraint(equalToConstant: 100),
            heightTextField.widthAnchor.constraint(equalToConstant: 100),
            
            labelSmaller.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            labelSmaller.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            labelSmaller.bottomAnchor.constraint(equalTo: self.bottomAnchor,constant: -2),
            labelSmaller.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.25),
        ])
    }
    
    
    // MARK: - Actions Base
    func update(with value: Int) {
        currentTypeSize = value
    }
    
    
    // MARK: - Actions @objc
    @objc private func didTapRotateLeft() {
        onRotateLeft?()
    }
    
    @objc private func didTapRotateRight() {
        onRotateRight?()
    }
    
    @objc private func didTapSwap() {
        onSwap?()
    }
}
