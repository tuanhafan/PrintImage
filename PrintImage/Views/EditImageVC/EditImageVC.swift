//
//  EditImageVC.swift
//  PrintImage
//
//  Created by Alex Tran on 21/7/25.
//

import UIKit

class EditImageVC: UIViewController {
    private let topBarView = UIView()
    private let images: [UIImage]
    private var imageEdit : ImageEdited?
    private var colorPicker =  ColorPickerView()
    private var photoEditToolView = PhotoEditToolView()
    
    init(images: [UIImage]) {
        self.images = images
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    private func setup(){
        view.backgroundColor = .secondaryLabel
        let containerViewRotate = ContainerViewRotate(images: images)
        colorPicker.isHidden = true
        photoEditToolView.isHidden = true
        topBarView.backgroundColor = .darkGray
        topBarView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(topBarView)
        view.addSubview(containerViewRotate)
        view.addSubview(colorPicker)
        view.addSubview(photoEditToolView)
        containerViewRotate.showLoading()
        
        NSLayoutConstraint.activate([
            topBarView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            topBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topBarView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.07),
        ])
        
        [containerViewRotate, colorPicker,photoEditToolView].forEach {
                    NSLayoutConstraint.activate([
                        $0.topAnchor.constraint(equalTo: topBarView.bottomAnchor, constant: 2),
                        $0.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                        $0.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                        $0.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                    ])
                }
        
        containerViewRotate.closeEditImage =  { [weak self] in
            guard let self = self else { return }
            self.navigationController?.popViewController(animated: true)
        }
        
        containerViewRotate.addImageToData =  { [weak self] imageEdited in
            guard let self = self else { return }
            imageEdit = imageEdited
            print(imageEdited)
        }
        
        containerViewRotate.openColorPickerView =  { [weak self] in
            guard let self = self else { return }
            showColorPickerView(containerViewRotate)
        }
        
        containerViewRotate.openPhotoTool =  { [weak self] image in
            guard let self = self else { return }
            showPhotoEditToolView(containerViewRotate)
            photoEditToolView.setImageEdit(image)
 
        }
        
        colorPicker.closePickerColor =  { [weak self] in
            guard let self = self else { return }
            containerViewRotate.isHidden = false
            colorPicker.isHidden = true
        }
       
        colorPicker.passData =  { [weak self] hextext in
            guard let self = self else { return }
            containerViewRotate.isHidden = false
            colorPicker.isHidden = true
            imageEdit?.backgroundColor = hextext
            containerViewRotate.imageBacground = hextext
        }
        
        photoEditToolView.closeView = { [weak self] in
            guard let self = self else { return }
            containerViewRotate.isHidden = false
            photoEditToolView.isHidden = true
        }
        
    }
    
    private func showColorPickerView(_ containerViewRotate: UIView){
        containerViewRotate.isHidden = true
        colorPicker.isHidden = false
        
    }
    
    private func showPhotoEditToolView(_ containerViewRotate: UIView){
        containerViewRotate.isHidden = true
        photoEditToolView.isHidden = false
        
    }
    private func checkHexImage() {
        guard let imageEdited = imageEdit else {
            colorPicker.hexColorText = "#ffffff"
            return
        }
        colorPicker.hexColorText = imageEdited.backgroundColor
    }
   
    
}
