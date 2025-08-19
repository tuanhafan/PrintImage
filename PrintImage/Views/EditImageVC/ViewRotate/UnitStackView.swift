//
//  TopView.swift
//  PrintImage
//
//  Created by Alex Tran on 5/8/25.
//

import UIKit

class UnitStackView: UIStackView {
    
    let mmLabel = UILabel()
    let cmLabel = UILabel()
    let inchLabel = UILabel()
    
    var onUnitTapped: ((Int) -> Void)? // callback khi label được nhấn
    
    private var labels: [UILabel] { [mmLabel, cmLabel, inchLabel] }
    
    var currentTypeSize: Int = 1 {
        didSet {
            for (index, label) in labels.enumerated() {
                if index  == currentTypeSize {
                    label.backgroundColor = .white
                    label.textColor = .black
                } else {
                    label.backgroundColor = .darkGray
                    label.textColor = .white
                }
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupStackView()
        setupLabels()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        setupStackView()
        setupLabels()
    }
    
    private func setupStackView() {
        axis = .horizontal
        alignment = .center
        distribution = .fillEqually
        backgroundColor = .white
        spacing = 1
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupLabels() {
        mmLabel.text = "mm"
        cmLabel.text = "cm"
        inchLabel.text = "inch"
        
        labels.enumerated().forEach { (index, label) in
            label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
            label.textColor = .white
            label.backgroundColor = .darkGray
            label.textAlignment = .center
            label.translatesAutoresizingMaskIntoConstraints = false
            label.isUserInteractionEnabled = true
            label.tag = index
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleLabelTap(_:)))
            label.addGestureRecognizer(tapGesture)
            
            addArrangedSubview(label)
            
            // Giữ nguyên constraint top & bottom như bạn viết
            label.topAnchor.constraint(equalTo: topAnchor, constant: 1).isActive = true
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -1).isActive = true
        }
    }
    
    @objc private func handleLabelTap(_ gesture: UITapGestureRecognizer) {
        guard let tappedLabel = gesture.view as? UILabel else { return }
        currentTypeSize = tappedLabel.tag
        onUnitTapped?(currentTypeSize)
        
    }
}

