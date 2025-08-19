//
//  CollectionViewCell.swift
//  PrintImage
//
//  Created by Alex Tran on 10/8/25.
//

import UIKit

class CustomPhotoFilterToolCell: UICollectionViewCell {
    static let identifier = "CellPhotoToolFilter"
    
    private let imageView = UIImageView()
    private let nameLabel = UILabel()
    private let containerView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        imageView.layer.cornerRadius = 5
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        nameLabel.textColor = .white
        nameLabel.font = UIFont.systemFont(ofSize: 10, weight: .medium)
        nameLabel.textAlignment = .center
        
        containerView.addSubview(imageView)
        containerView.addSubview(nameLabel)
        contentView.addSubview(containerView)
        
        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            containerView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.9),
            containerView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.7),
            
            imageView.topAnchor.constraint(equalTo: containerView.topAnchor),
            imageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            imageView.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 0.6),
            imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor),
        
            nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 5),
            nameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            nameLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
    }
    
    func configuaration(with item: (info: FilterInfo, image: UIImage)) {
        imageView.image = item.image
        nameLabel.text = item.info.display
    }
}
