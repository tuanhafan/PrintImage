//
//  MyCollectionViewHandler.swift
//  PrintImage
//
//  Created by Alex Tran on 15/7/25.
//

import Foundation
import UIKit

final class HomeCollectionViewHandler: NSObject, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // MARK: - Public
    var items: [String] = [] {
        didSet {
            updateEmptyState()
        }
    }
    
    private var spacingRatio: CGFloat {
        let width = UIScreen.main.bounds.width
        return width >= 768 ? 0.03 : 0.001 // iPad ~3%, iPhone ~1.5%
    }
    
    var onItemSelected: ((IndexPath) -> Void)?
    var onRetryTapped: (() -> Void)?
    
    weak var collectionView: UICollectionView?
    
    // MARK: - Setup
    init(collectionView: UICollectionView) {
        self.collectionView = collectionView
        super.init()
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(HomeCollectionViewCell.self, forCellWithReuseIdentifier: HomeCollectionViewCell.identifier)
        setupEmptyButton()
    }
    
    // MARK: - UICollectionView DataSource & Delegate
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeCollectionViewCell.identifier, for: indexPath) as? HomeCollectionViewCell else
        {
            return UICollectionViewCell()
        }
        cell.contentView.backgroundColor = .systemBlue
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        onItemSelected?(indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView,layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        let spacing = collectionView.bounds.width * spacingRatio
        return UIEdgeInsets(top: spacing, left: 0, bottom: spacing, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView,layout collectionViewLayout: UICollectionViewLayout,minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return collectionView.bounds.width * spacingRatio
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return ((collectionView.bounds.width  * spacingRatio) + 1)
    }
    
    func collectionView(_ collectionView: UICollectionView,layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let isIpad = UIDevice.current.userInterfaceIdiom == .pad
        let itemsPerRow: CGFloat = isIpad ? 4 : 2
        let spacing = collectionView.bounds.width * spacingRatio
        let totalSpacing = spacing * (itemsPerRow + 1)
        
        let availableWidth = collectionView.bounds.width - totalSpacing
        let itemWidth = floor(availableWidth / itemsPerRow)
        
        return CGSize(width: itemWidth, height: itemWidth * (4/5))
    }
    
    // MARK: - Empty View
    private let emptyButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: ResponsiveLayout.emptyButtonSize(), weight: .regular)
        let image = UIImage(systemName: "plus.circle", withConfiguration: config)
        button.setImage(image, for: .normal)
        button.tintColor = UIColor(white: 1.0, alpha: 0.25)
        button.clipsToBounds = true
        
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private func setupEmptyButton() {
        emptyButton.addTarget(self, action: #selector(retryTapped), for: .touchUpInside)
        emptyButton.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func updateEmptyState() {
        guard let collectionView = collectionView else { return }
        
        if items.isEmpty {
            let wrapper = UIView()
            wrapper.addSubview(emptyButton)
            
            NSLayoutConstraint.activate([
                emptyButton.centerXAnchor.constraint(equalTo: wrapper.centerXAnchor),
                emptyButton.centerYAnchor.constraint(equalTo: wrapper.centerYAnchor)
            ])
            
            collectionView.backgroundView = wrapper
        } else {
            collectionView.backgroundView = nil
        }
        
        collectionView.reloadData()
    }
    
    @objc private func retryTapped() {
        onRetryTapped?()
    }
    
}
