//
//  BottomBarView.swift
//  PrintImage
//
//  Created by Alex Tran on 6/8/25.
//

import UIKit

final class BottomBarView: UIView {
    let closeBtn = ButtonIcon.createIconButton(systemName: "xmark")
    let checkmarkBtn = ButtonIcon.createIconButton(systemName: "checkmark")
    let labelCount = UILabel()
    var onClose: (() -> Void)?
    var onNextImage: (() -> Void)?
    var currentNumerImage : (currentImage: Int, totalImage:Int) = (0,0) {
        
        didSet {
            if(currentNumerImage.totalImage <= 1) {
                labelCount.isHidden = true
            }
            else {
                labelCount.text = "\(currentNumerImage.currentImage ) / \(currentNumerImage.totalImage)"
            }
           
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        backgroundColor = .darkGray
        translatesAutoresizingMaskIntoConstraints = false

        let subStackView = UIStackView()
        subStackView.axis = .horizontal
        subStackView.distribution = .equalSpacing
        subStackView.alignment = .center
        subStackView.translatesAutoresizingMaskIntoConstraints = false
        subStackView.isLayoutMarginsRelativeArrangement = true
        subStackView.layoutMargins = UIEdgeInsets(top: 5, left: ResponsiveLayout.horizontalMargin(), bottom: 5, right: ResponsiveLayout.horizontalMargin())

        labelCount.textColor = .white
        labelCount.font = UIFont.systemFont(ofSize: 18)

        checkmarkBtn.tintColor = .systemBlue

        closeBtn.addTarget(self, action: #selector(closeEditImage), for: .touchUpInside)
        checkmarkBtn.addTarget(self, action: #selector(nextImage), for: .touchUpInside)
        
        subStackView.addArrangedSubview(closeBtn)
        subStackView.addArrangedSubview(labelCount)
        subStackView.addArrangedSubview(checkmarkBtn)

        addSubview(subStackView)

        NSLayoutConstraint.activate([
            subStackView.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            subStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            subStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }
    
    @objc func closeEditImage() {
        onClose?()
    }
    
    @objc func nextImage() {
        onNextImage?()
    }
}
