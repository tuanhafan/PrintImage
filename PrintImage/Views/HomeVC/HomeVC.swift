//
//  HomeVC.swift
//  PrintImage
//
//  Created by Alex Tran on 14/7/25.
//

import UIKit

class HomeVC: UIViewController {
    
    private let topBarView = UIView()
    private let mediaSelectView = UIStackView()
    private let bottomBarView = UIView()
    private let collectionViewMain = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private var handler: HomeCollectionViewHandler!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .secondaryLabel
        
        setupTopBar()
        setupMediaSelectBar()
        setupBottomBar()
        setupCollectionView()
        
        
        handler = HomeCollectionViewHandler(collectionView: collectionViewMain)
        
        handler.items = ["1","1","1","1",]
        handler.onItemSelected = { indexPath in
            print("Bạn chọn item tại \(indexPath.row)")
        }
        
        handler.onRetryTapped = {
            print("Đã nhấn thử lại")
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    private func setupTopBar() {
        topBarView.backgroundColor = .darkGray
        topBarView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(topBarView)
        
        NSLayoutConstraint.activate([
            topBarView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            topBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topBarView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.07)
        ])
    }
    
    private func setupMediaSelectBar() {
        mediaSelectView.axis = .horizontal
        mediaSelectView.alignment = .center
        mediaSelectView.distribution = .equalSpacing
        mediaSelectView.spacing = ResponsiveLayout.bottomSpacing()
        mediaSelectView.translatesAutoresizingMaskIntoConstraints = false
        mediaSelectView.backgroundColor = UIColor.darkGray
        mediaSelectView.isLayoutMarginsRelativeArrangement = true
        mediaSelectView.layoutMargins = UIEdgeInsets(top: 12, left: ResponsiveLayout.horizontalMargin(), bottom: 12, right: ResponsiveLayout.horizontalMargin())
        
        // Add buttons
        let photoButton = ButtonIcon.createIconButton(systemName: "photo.on.rectangle")
        let trashButton = ButtonIcon.createIconButton(systemName: "trash.fill", badgeNumber: 2)
        let infoButton = ButtonIcon.createIconButton(systemName: "info.circle")
        
        [photoButton, trashButton, infoButton].forEach { btn in
            btn.widthAnchor.constraint(equalToConstant: ResponsiveLayout.buttonSize()).isActive = true
            btn.heightAnchor.constraint(equalToConstant: ResponsiveLayout.buttonSize()).isActive = true
            mediaSelectView.addArrangedSubview(btn)
        }
        
        
        mediaSelectView.backgroundColor = .darkGray
        mediaSelectView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mediaSelectView)
        
        NSLayoutConstraint.activate([
            
            
            
            mediaSelectView.topAnchor.constraint(equalTo: topBarView.bottomAnchor, constant: 2),
            mediaSelectView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mediaSelectView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
        ])
    }
    
    private func setupCollectionView() {
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 10
        layout.itemSize = CGSize(width: 100, height: 100)
        
        collectionViewMain.backgroundColor = .clear
        collectionViewMain.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionViewMain)
        
        
        
        
        NSLayoutConstraint.activate([
            collectionViewMain.topAnchor.constraint(equalTo: mediaSelectView.bottomAnchor, constant: 2),
            collectionViewMain.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            collectionViewMain.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            collectionViewMain.bottomAnchor.constraint(equalTo: bottomBarView.topAnchor, constant: -12)
        ])
    }
    
    private func setupBottomBar() {
        bottomBarView.backgroundColor = .darkGray
        bottomBarView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bottomBarView)
        
        NSLayoutConstraint.activate([
            bottomBarView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),
            bottomBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomBarView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.06)
        ])
    }
    
    
    
    
}

