//
//  HomeCollectionViewCell.swift
//  PrintImage
//
//  Created by Alex Tran on 15/7/25.
//

import UIKit

class HomeCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "MediaToolCell"
    
    // MARK: - Views
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private let viewTop : UIView = {
        let view = UIView()
        let label = UILabel()
        label.textColor = .white
        label.backgroundColor = .darkGray
        label.textAlignment = .center
        label.text = "5.8 x 8.5 mm"
        label.font = UIFont.systemFont(ofSize: ResponsiveLayout.fontSize(base: 14), weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            label.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            label.bottomAnchor.constraint(equalTo: view.bottomAnchor,constant: 0)
        ])
        return view
    }()
    
    private let viewContentImg : UIView = {
        let view = UIView()
        let imageView = UIImageView()
        imageView.image = UIImage(named: "test2")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .lightGray
        
        view.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.9),
            imageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.6),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        return view
    }()
    
    
    private let viewBottom : UIView = {
        let view = UIView()
        let stackView = UIStackView()
        stackView.alignment = .center
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        // MARK: - set up subview in stackview
        
        let btnTrash = ButtonIcon.btnInCell("trash.fill")
        let btnCrop = ButtonIcon.btnInCell("crop")
        
        
        // MARK: - set up subview in stackViewCount
        
        let stackViewCount = UIStackView()
        stackViewCount.axis = .horizontal
        stackViewCount.distribution = .equalSpacing

        let btnMinus = ButtonIcon.btnInCell("minus.square.fill")
        
        let viewLabel = UIView()
        let label = UILabel()
        
        label.textAlignment = .center
        label.textColor = .white
        label.text = "1"
        label.font = UIFont.systemFont(ofSize: ResponsiveLayout.fontSize(base: 12), weight: .bold)
        viewLabel.backgroundColor = .secondaryLabel
        viewLabel.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        viewLabel.addSubview(label)
        
        let btnPlus = ButtonIcon.btnInCell("plus.square.fill")
        
        stackViewCount.addArrangedSubview(btnMinus)
        stackViewCount.addArrangedSubview(viewLabel)
        stackViewCount.addArrangedSubview(btnPlus)
        
        // MARK: - stackview
        
        stackView.addArrangedSubview(btnTrash)
        stackView.addArrangedSubview(stackViewCount)
        stackView.addArrangedSubview(btnCrop)
        
        view.backgroundColor = .darkGray
        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            
            
            viewLabel.widthAnchor.constraint(equalTo: stackViewCount.widthAnchor, multiplier: 0.5),
            label.leadingAnchor.constraint(equalTo: viewLabel.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: viewLabel.trailingAnchor),
            label.topAnchor.constraint(equalTo: viewLabel.topAnchor),
            label.bottomAnchor.constraint(equalTo: viewLabel.bottomAnchor),
            
            
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: 7),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant: -7),
            stackView.topAnchor.constraint(equalTo: view.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        return view
    }()
    
    
    private func setupCell () {
        contentView.addSubview(viewTop)
        contentView.addSubview(viewContentImg)
        contentView.addSubview(viewBottom)
        
        
        NSLayoutConstraint.activate([
            
            viewTop.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            viewTop.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
            viewTop.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            viewTop.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.2),

            viewContentImg.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            viewContentImg.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
            viewContentImg.topAnchor.constraint(equalTo: viewTop.bottomAnchor, constant: 0),
            viewContentImg.bottomAnchor.constraint(equalTo: viewBottom.topAnchor, constant: 0),
            viewContentImg.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.6),
            
            viewBottom.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            viewBottom.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
            viewBottom.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0),
            
        ])
    }
    
    
}

