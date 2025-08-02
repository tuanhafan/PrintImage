//
//  CollectionViewSlider.swift
//  PrintImage
//
//  Created by Alex Tran on 23/7/25.
//

import UIKit


class CollectionViewSlider: NSObject, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout  {

    private let editImageModel = EditImageModel()
    private var paperSizes : [PaperSize] = []
    
    weak var collectionView: UICollectionView?
       init(collectionView: UICollectionView) {
           self.paperSizes = editImageModel.paperSizes
           self.collectionView = collectionView
           super.init()
           collectionView.register(CustomCellSlider.self, forCellWithReuseIdentifier: CustomCellSlider.identifier)
           collectionView.dataSource = self
           collectionView.delegate = self
           collectionView.isPagingEnabled = false
           collectionView.showsHorizontalScrollIndicator = false
           collectionView.bounces = false

       }


       // MARK: - DataSource
       func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
           return paperSizes.count
       }

       func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
           let paperSize : PaperSize = paperSizes[indexPath.row]
           guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CustomCellSlider.identifier, for: indexPath) as? CustomCellSlider else {
               return UICollectionViewCell()
           }
           cell.configuaration(with: paperSize)
           return cell
       }

       // MARK: - FlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
           let numberOfItemsPerScreen: CGFloat = 4.5
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
