//
//  EmojiSliderView.swift
//  PrintImage
//
//  Created by Alex Tran on 16/8/25.
//

import Foundation
import UIKit

class StickerSliderView: UIView {
    
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    
    
    var onEmojiSelected: ((Int) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    
    private func setupUI() {
        scrollView.showsHorizontalScrollIndicator = false
        addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        
        stackView.axis = .horizontal
        stackView.spacing = 20
        scrollView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor,constant:15),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
        ])
        
        // Tạo các nút emoji
        for index in 1...35 {
            if let image = UIImage(named: "\(index)") {
                let imageView = UIImageView(image: image)
                imageView.contentMode = .scaleAspectFit
                imageView.isUserInteractionEnabled = true  // bắt buộc để nhận gesture
                
                // fix size
                imageView.widthAnchor.constraint(equalToConstant: 50).isActive = true
                imageView.heightAnchor.constraint(equalToConstant: 50).isActive = true
                
                // set tag
                imageView.tag = index
                
                // add gesture
                let tap = UITapGestureRecognizer(target: self, action: #selector(emojiTapped(_:)))
                imageView.addGestureRecognizer(tap)
                
                stackView.addArrangedSubview(imageView)
            }
        }
    }
    
    @objc private func emojiTapped(_ sender: UITapGestureRecognizer) {
        guard let tappedImageView = sender.view as? UIImageView else { return }
        let index = tappedImageView.tag
        onEmojiSelected?(index)
    }
}
