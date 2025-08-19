//
//  ColorPickerView.swift
//  PrintImage
//
//  Created by Alex Tran on 6/8/25.
//

import UIKit

class ColorPickerView: UIView {
    
    // MARK: - UI Components
    private let colorPreview = UIView()
    private let hexTextField = UITextField()
    private let colorConfirmView = UIStackView()
    private let colorSpectrumView = ColorSpectrumView()
    private let brightnessSliderView = UIView()
    private let sliderBrightNessColor = UIView()
    private let colorSlider = ColorSliderView()
    private let containerView = UIView()
    private let maxCharacters = 6
    private var didLayoutOnce = false
    var closePickerColor: (() -> Void)?
    var passData: ((_ hexText : String) -> Void)?
    
    var hexColorText : String = "#ffffff" {
        didSet {
            
            hexTextField.text = removeHashPrefix(hexColorText).uppercased()
            colorPreview.backgroundColor = UIColor(hexString: hexColorText)
        }
    }
    
    let gradientColorView = UIView()
    let brightnessSlider = UIView()
    
    
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
        setupConstraints()
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if !didLayoutOnce {
            didLayoutOnce = true
            setupLayout()
            setupColorConfirmView()
            setupBrightnessSliderView()
        }
    }
    
    
    
    // MARK: - Setup UI
    private func setupViews() {
        backgroundColor = .darkGray
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    // MARK: - Constraints with multiplier
    
    
    private func setupConstraints() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = .clear
        self.addSubview(containerView)
        
        [colorConfirmView,colorSpectrumView,brightnessSliderView].forEach {
            containerView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.backgroundColor = .clear
        }
        
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: self.topAnchor, constant: 10),
            containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -40),
        ])
        actionsView()
    }
    
    private func setupLayout() {
        
        NSLayoutConstraint.activate([
            
            colorConfirmView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 0),
            colorConfirmView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            colorConfirmView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            colorConfirmView.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 0.1),
            
            colorSpectrumView.topAnchor.constraint(equalTo: colorConfirmView.bottomAnchor,constant: 15),
            colorSpectrumView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            colorSpectrumView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            colorSpectrumView.bottomAnchor.constraint(equalTo: brightnessSliderView.topAnchor,constant: -20),
            
            brightnessSliderView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            brightnessSliderView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            brightnessSliderView.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 0.05),
            brightnessSliderView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
        ])
        
    }
    
    private func setupColorConfirmView(){
        let okButton = UIButton()
        let cancelButton = UIButton()
        let stackViewTop = UIStackView()
        let stackViewBottom = UIStackView()
        let hashLabel = UILabel()
        
        hashLabel.text = "#"
        hashLabel.font = hexTextField.font
        hashLabel.textColor = .label
        hashLabel.sizeToFit()
        let paddedView = UIView(frame: CGRect(x: 0, y: 0, width: hashLabel.frame.width + 10, height: hashLabel.frame.height))
        hashLabel.frame.origin = CGPoint(x: 10, y: 0)
        paddedView.addSubview(hashLabel)
        
        
        okButton.setTitle("OK", for: .normal)
        cancelButton.setTitle("Huỷ", for: .normal)
        okButton.addTarget(self, action: #selector(passDataHex), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(closePickerView), for: .touchUpInside)
        
        [okButton,cancelButton].forEach{
            $0.backgroundColor = .lightText
            $0.layer.cornerRadius = 5
            $0.setTitleColor(.black, for: .normal)
            $0.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        }
        
        hexTextField.leftView = paddedView
        hexTextField.textAlignment = .center
        hexTextField.leftViewMode = .always
        hexTextField.autocapitalizationType = .allCharacters
        hexTextField.backgroundColor = .white
        hexTextField.layer.cornerRadius = 5
        
        colorPreview.layer.cornerRadius = 5
        colorPreview.backgroundColor = .white
        
        colorConfirmView.axis = .vertical
        colorConfirmView.spacing = 10
        colorConfirmView.distribution = .equalSpacing
        
        [stackViewTop,stackViewBottom].forEach{
            $0.axis = .horizontal
            $0.spacing = 15
            $0.distribution = .fillEqually
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        
        stackViewTop.addArrangedSubview(okButton)
        stackViewTop.addArrangedSubview(colorPreview)
        
        stackViewBottom.addArrangedSubview(cancelButton)
        stackViewBottom.addArrangedSubview(hexTextField)
        
        colorConfirmView.addArrangedSubview(stackViewTop)
        colorConfirmView.addArrangedSubview(stackViewBottom)
        
        
        
    }
    
    private func setupBrightnessSliderView(){
        let whiteBtn = UIButton()
        let blackBtn = UIButton()
        let stackView = UIStackView()
        
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.spacing = 15
        
        [blackBtn,whiteBtn].forEach {
            $0.layer.cornerRadius = 0
            $0.layer.borderWidth = 1
            $0.layer.borderColor = UIColor.lightGray.cgColor
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.widthAnchor.constraint(equalTo: $0.heightAnchor).isActive = true
        }
        blackBtn.addTarget(self, action: #selector(setColorBlack), for: .touchUpInside)
        whiteBtn.addTarget(self, action: #selector(setColorWhite), for: .touchUpInside)
        
        whiteBtn.backgroundColor = .white
        blackBtn.backgroundColor = .black
        stackView.addArrangedSubview(whiteBtn)
        stackView.addArrangedSubview(colorSlider)
        stackView.addArrangedSubview(blackBtn)
        
        brightnessSliderView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: brightnessSliderView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: brightnessSliderView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: brightnessSliderView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: brightnessSliderView.bottomAnchor),
        ])
        
    }
    
    private func actionsView(){
        colorSpectrumView.onColorPicked = { [weak self] selectedColor in
            guard let self = self else { return }
            hexColorText = "\(selectedColor.toHexString())"
            colorSlider.baseHexColor = "\(selectedColor.toHexString())"
        }
        
        colorSlider.onColorChanged = { [weak self] hex in
            guard let self = self else { return }
            hexColorText = hex
        }
    }
    
    
}

extension ColorPickerView : UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let allowedCharacters = CharacterSet(charactersIn: "ABCDEF0123456789")
        let uppercaseString = string.uppercased()
        
        // Nếu ký tự nhập vào không hợp lệ
        if uppercaseString.rangeOfCharacter(from: allowedCharacters.inverted) != nil {
            return false
        }
        
        // Tính độ dài sau khi thay đổi
        if let currentText = textField.text as NSString? {
            let newText = currentText.replacingCharacters(in: range, with: uppercaseString)
            return newText.count <= maxCharacters
        }
        
        return true
    }
    
    private func removeHashPrefix(_ text: String) -> String {
        var result = text
        if result.hasPrefix("#") {
            result.removeFirst()
        }
        return result
    }
    
    @objc func setColorWhite() {
        hexColorText = "#ffffff"
        colorSlider.baseHexColor = "#ffffff"
        colorSlider.selectedPosition = 0.0
    }
    
    @objc func setColorBlack(){
        hexColorText = "#ffffff"
        colorSlider.baseHexColor = "#000000"
        colorSlider.selectedPosition = 1.0
    }
    
    @objc func closePickerView() {
        closePickerColor?()
    }
    
    @objc func passDataHex() {
        passData?(hexColorText)
    }
}
