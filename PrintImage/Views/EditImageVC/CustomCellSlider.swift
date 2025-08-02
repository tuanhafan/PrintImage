//
//  CustomCellSlider.swift
//  PrintImage
//
//  Created by Alex Tran on 23/7/25.
//

import UIKit

class CustomCellSlider: UICollectionViewCell {
    static let identifier = "CellSlider"
    
    private var widthConstraint: NSLayoutConstraint?
    private var heightConstraint: NSLayoutConstraint?
    
    private let labelName : UILabel = {
        let label = UILabel()
        label.backgroundColor = .systemGray
        label.font = UIFont.systemFont(ofSize: 9, weight: .medium)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let viewPaperSize : UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Views
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        labelName.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.25).isActive = true
        
        
    }
    
    
    func configuaration(with  paperSize : PaperSize){
        labelName.text = paperSize.name
        
        
        widthConstraint?.isActive = false
        heightConstraint?.isActive = false
        
        var widthMultiplier: CGFloat = 0.3
        var heightMultiplier: CGFloat = 0.5
        
        switch paperSize.value {
        case 1: widthMultiplier = 0.2
        case 2: widthMultiplier = 0.3
        case 3: widthMultiplier = 0.35
        case 4: widthMultiplier = 0.45
        case 5: widthMultiplier = 0.35
        case 6:
            widthMultiplier = 0.6
            heightMultiplier = 0.4
        case 7: widthMultiplier = 0.3
        case 8: widthMultiplier = 0.35
        case 9: widthMultiplier = 0.25
        default: break
        }
        
        heightConstraint = viewPaperSize.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: heightMultiplier)
        widthConstraint = viewPaperSize.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: widthMultiplier)
        
        heightConstraint?.isActive = true
        widthConstraint?.isActive = true
        
        
    }
    
    private func setup(){
        self.backgroundColor = .darkGray
        contentView.addSubview(labelName)
        contentView.addSubview(viewPaperSize)
        NSLayoutConstraint.activate([
            labelName.topAnchor.constraint(equalTo: contentView.topAnchor),
            labelName.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            labelName.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            
            viewPaperSize.topAnchor.constraint(equalTo: labelName.bottomAnchor,constant: 10),
            viewPaperSize.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
        ])
        
    }
    
}
