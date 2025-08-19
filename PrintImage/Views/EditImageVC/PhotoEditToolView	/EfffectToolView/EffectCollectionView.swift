//
//  CollectionViewSlider.swift
//  PrintImage
//
//  Created by Alex Tran on 23/7/25.
//

import UIKit


import UIKit

class EffectCollectionView: NSObject, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var didSelectFilter: ((FilterInfo, UIImage) -> Void)?
    private let photoEditToolModel = PhotoEditToolModel()
    private var filteredImages: [(info: FilterInfo, image: UIImage)] = []
    private var filterNames: [FilterInfo]
    
    var originalImage: UIImage? {
       
        didSet {
            generateFilteredImages()
        }
    }
    
    weak var collectionView: UICollectionView?
    
    init(collectionView: UICollectionView) {
        self.filterNames = photoEditToolModel.effects
        self.collectionView = collectionView
        super.init()
        
        collectionView.register(CustomEffectToolCell.self,
                                forCellWithReuseIdentifier: CustomEffectToolCell.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isPagingEnabled = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.bounces = false
    }
    
    private func generateFilteredImages() {
        filteredImages.removeAll()
        guard let originalImage = originalImage else {
            print("⚠️ originalImage chưa được set")
            return
        }
        
        for filter in filterNames {
            let filtered = EffectProcessor.applyFilter(name: filter.ciName, to: originalImage)
            filteredImages.append((filter, filtered))
        }
        
        collectionView?.reloadData()
    }
    
    // MARK: - CollectionView DataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let filterData = filteredImages[indexPath.item]
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CustomEffectToolCell.identifier,
            for: indexPath
        ) as? CustomEffectToolCell else {
            return UICollectionViewCell()
        }
        
        cell.configuaration(with: filterData)
        return cell
    }
    
    // MARK: - CollectionView Delegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let filterData = filteredImages[indexPath.item]
        didSelectFilter?(filterData.info, filterData.image)
    }
    
    // MARK: - FlowLayout
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let numberOfItemsPerScreen: CGFloat = 6
        let layout = collectionViewLayout as! UICollectionViewFlowLayout
        let spacing = layout.minimumLineSpacing
        let sectionInset = layout.sectionInset.left + layout.sectionInset.right
        
        let totalSpacing = spacing * (numberOfItemsPerScreen - 1) + sectionInset
        let availableWidth = collectionView.bounds.width - totalSpacing
        let itemWidth = availableWidth / numberOfItemsPerScreen
        let itemHeight = collectionView.bounds.height
        return CGSize(width: itemWidth, height: itemHeight)
    }
}
