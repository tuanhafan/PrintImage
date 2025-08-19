//
//  CollectionViewSlider.swift
//  PrintImage
//
//  Created by Alex Tran on 23/7/25.
//

import UIKit


class CollectionViewPhotoTool: NSObject, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout  {

    private let photoEditToolModel = PhotoEditToolModel()
    private var listool : [ItemTool] = []
    var currentImage: (width: CGFloat, height: CGFloat) = (0,0)
    var onSizeSelected: ((Int) -> Void)?
    
    weak var collectionView: UICollectionView?
       init(collectionView: UICollectionView) {
           self.listool = photoEditToolModel.listTool
           self.collectionView = collectionView
           super.init()
           collectionView.register(CustomPhotoEditToolCell.self, forCellWithReuseIdentifier: CustomPhotoEditToolCell.identifier)
           collectionView.dataSource = self
           collectionView.delegate = self
           collectionView.isPagingEnabled = false
           collectionView.showsHorizontalScrollIndicator = false
           collectionView.bounces = false

       }


       // MARK: - DataSource
       func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
           return listool.count
       }

       func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
           let itemTool : ItemTool = listool[indexPath.row]
           guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CustomPhotoEditToolCell.identifier, for: indexPath) as? CustomPhotoEditToolCell else {
               return UICollectionViewCell()
           }
           cell.configuaration(with: itemTool)
           return cell
       }

       // MARK: - FlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
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

    //
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        onSizeSelected?(indexPath.row + 1)
    }
}
