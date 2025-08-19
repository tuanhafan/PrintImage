//
//  CustomPhotoEditToolCell.swift
//  PrintImage
//
//  Created by Alex Tran on 9/8/25.
//

import UIKit

class CustomPhotoEditToolCell: UICollectionViewCell {
    static let identifier = "CellPhotoTool"
    private let image = UIImageView()
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
        image.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
     
        image.contentMode = .scaleAspectFit
        image.tintColor = .white
        
        nameLabel.textColor = .white
        nameLabel.font = UIFont.systemFont(ofSize: 10, weight: .medium)
        nameLabel.textAlignment = .center
        
        containerView.addSubview(image)
        containerView.addSubview(nameLabel)
        contentView.addSubview(containerView)
        
        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            containerView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.9),
            containerView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.7),
            
            image.topAnchor.constraint(equalTo: containerView.topAnchor),
            image.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            image.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            image.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 0.6),
            
            nameLabel.topAnchor.constraint(equalTo: image.bottomAnchor, constant: 10),
            nameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            nameLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            
        ])
    }
    
    func configuaration(with item: ItemTool){
        image.image = UIImage(systemName: item.nameImage)
        nameLabel.text = item.name
    }
}
