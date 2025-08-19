//
//  TextToolBarView.swift
//  PrintImage
//
//  Created by Alex Tran on 17/8/25.
//

import Foundation
import UIKit

enum ToolBarAction: Int {
    case new = 0
    case text
    case color
    case font
}

class TextToolBarView: UIView {
    
    var onActionTapped: ((ToolBarAction) -> Void)?
        
        private var buttons: [UIButton] = []
        private var labels: [Int: UILabel] = [:]
        private var icons: [Int: UIImageView] = [:]
        
        private let stackView: UIStackView = {
            let sv = UIStackView()
            sv.axis = .horizontal
            sv.alignment = .center
            sv.distribution = .equalSpacing
            sv.spacing = 24
            return sv
        }()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            setupView()
        }
        
        required init?(coder: NSCoder) {
            super.init(coder: coder)
            setupView()
        }
        
        private func setupView() {
            addSubview(stackView)
            stackView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                stackView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
                stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
                stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
                stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
            ])
            
            let newBtn = makeButton(icon: UIImage(systemName: "plus.circle")!,
                                    title: "Mới",
                                    tag: ToolBarAction.new.rawValue,
                                    active: true)
            let textBtn = makeButton(icon: UIImage(systemName: "textformat")!,
                                     title: "Văn bản",
                                     tag: ToolBarAction.text.rawValue,
                                     active: false)
            let colorBtn = makeColorButton(color: .systemPink,
                                           title: "Màu sắc",
                                           tag: ToolBarAction.color.rawValue,
                                           active: false)
            let fontBtn = makeButton(icon: UIImage(systemName: "textformat.size")!,
                                     title: "Kiểu chữ",
                                     tag: ToolBarAction.font.rawValue,
                                     active: false)
            
            buttons = [newBtn, textBtn, colorBtn, fontBtn]
            buttons.forEach { stackView.addArrangedSubview($0) }
        }
        
    private func makeButton(icon: UIImage, title: String, tag: Int, active: Bool) -> UIButton {
        let button = UIButton(type: .system)
        button.tag = tag
        
        let iv = UIImageView(image: icon)
        iv.tintColor = active ? .white : .lightGray
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.widthAnchor.constraint(equalToConstant: 32).isActive = true
        iv.heightAnchor.constraint(equalToConstant: 32).isActive = true
        
        let label = UILabel()
        label.text = title
        label.textColor = active ? .white : .lightGray
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .center
        
        let sv = UIStackView(arrangedSubviews: [iv, label])
        sv.axis = .vertical
        sv.alignment = .center
        sv.spacing = 4
        
        button.addSubview(sv)
        sv.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            sv.centerXAnchor.constraint(equalTo: button.centerXAnchor),
            sv.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            sv.topAnchor.constraint(equalTo: button.topAnchor, constant: 4),
            sv.bottomAnchor.constraint(equalTo: button.bottomAnchor, constant: -4),
            sv.leadingAnchor.constraint(equalTo: button.leadingAnchor, constant: 4),
            sv.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: -4)
        ])
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        sv.addGestureRecognizer(tap)
        labels[tag] = label
        icons[tag] = iv
        return button
    }
        
        private func makeColorButton(color: UIColor, title: String, tag: Int, active: Bool) -> UIButton {
            let button = UIButton(type: .system)
            button.tag = tag
            
            let tint = active ? UIColor.white : UIColor.lightGray
            
            let colorView = UIView()
            colorView.backgroundColor = color
            colorView.layer.cornerRadius = 4
            colorView.layer.borderColor = UIColor.black.cgColor
            colorView.layer.borderWidth = 2
            colorView.translatesAutoresizingMaskIntoConstraints = false
            colorView.widthAnchor.constraint(equalToConstant: 32).isActive = true
            colorView.heightAnchor.constraint(equalToConstant: 32).isActive = true
            
            let label = UILabel()
            label.text = title
            label.textColor = tint
            label.font = UIFont.systemFont(ofSize: 12)
            label.textAlignment = .center
            
            let sv = UIStackView(arrangedSubviews: [colorView, label])
            sv.axis = .vertical
            sv.alignment = .center
            sv.spacing = 4
            sv.translatesAutoresizingMaskIntoConstraints = false
            sv.isUserInteractionEnabled = false
            
            button.addSubview(sv)
            NSLayoutConstraint.activate([
                sv.topAnchor.constraint(equalTo: button.topAnchor),
                    sv.bottomAnchor.constraint(equalTo: button.bottomAnchor),
                    sv.leadingAnchor.constraint(equalTo: button.leadingAnchor),
                    sv.trailingAnchor.constraint(equalTo: button.trailingAnchor)
            ])
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
            sv.addGestureRecognizer(tap)
            
            // lưu label (colorView thì không đổi màu nền, chỉ label cần đổi)
            labels[tag] = label
            
            return button
        }
        
        @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
            guard let tappedView = gesture.view else { return }
               let tag = tappedView.tag   // ✅ Lấy tag từ view
               if let action = ToolBarAction(rawValue: tag) {
                   if action == .new {
                       setButtonsActive(true)
                   }
                   onActionTapped?(action)
               }
        }
        
        private func setButtonsActive(_ active: Bool) {
            for (tag, label) in labels {
                if let action = ToolBarAction(rawValue: tag), action != .new {
                    label.textColor = active ? .white : .lightGray
                }
            }
            for (tag, icon) in icons {
                if let action = ToolBarAction(rawValue: tag), action != .new {
                    icon.tintColor = active ? .white : .lightGray
                }
            }
        }
    }
