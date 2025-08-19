//
//  FilterCollectionView.swift
//  PrintImage
//
//  Created by Alex Tran on 10/8/25.
//
import UIKit


class FilterCollectionView: NSObject, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
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
           self.filterNames = photoEditToolModel.filterNames
           self.collectionView = collectionView
           super.init()
           collectionView.register(CustomPhotoFilterToolCell.self, forCellWithReuseIdentifier: CustomPhotoFilterToolCell.identifier)
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
            if let filtered = applyFilter(to: originalImage, filterName: filter.ciName) {
                filteredImages.append((filter, filtered))
            }
        }
        self.collectionView?.reloadData()
    }
    
    private func applyFilter(to image: UIImage, filterName: String) -> UIImage? {
        guard let ciImage = CIImage(image: image),
              let filter = CIFilter(name: filterName) else { return nil }
        
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        
        if filterName == "CIVignette" {
            filter.setValue(2.0, forKey: kCIInputIntensityKey)
            filter.setValue(30.0, forKey: kCIInputRadiusKey)
        }
        if filterName == "CISepiaTone" {
            filter.setValue(1.0, forKey: kCIInputIntensityKey)
        }
        if filterName == "CIColorMonochrome" {
            filter.setValue(CIColor(red: 0.7, green: 0.7, blue: 0.9), forKey: kCIInputColorKey)
            filter.setValue(1.0, forKey: kCIInputIntensityKey)
        }
        
        let context = CIContext()
        guard let outputImage = filter.outputImage,
              let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else {
            return nil
        }
        
        return UIImage(cgImage: cgImage)
    }
    
    // MARK: - CollectionView Delegate/DataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let filterData = filteredImages[indexPath.item]
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CustomPhotoFilterToolCell.identifier, for: indexPath) as? CustomPhotoFilterToolCell else {
            return UICollectionViewCell()
        }
        cell.configuaration(with: filterData)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let filterData = filteredImages[indexPath.item]
        didSelectFilter?(filterData.info, filterData.image)
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
}
