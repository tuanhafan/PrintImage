//
//  SlideContainerView.swift
//  PrintImage
//
//  Created by Alex Tran on 18/8/25.
//

import Foundation
import UIKit


final class SlideTextView: UIView, UIScrollViewDelegate {
    
    private let scrollView = UIScrollView()
    private let pageControl = UIPageControl()
    
    private let numberOfPages = 3
    private var initialPage: Int = 0
    private let deleteButton = UIButton(type: .custom)
    private let textView = UITextView()
    private let viewContainerText = UIView()
    private let colorTextPickerView = ColorTextPickerView()
    
    init(initialPage: Int) {
        
        super.init(frame: .zero)
        self.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        self.initialPage = max(0, min(initialPage, numberOfPages - 1))
        setupScrollView()
        setupPages()
        setupPageControl()
        setupDeleteButton()
        setupTextView()
        // hiển thị đúng page ban đầu
        DispatchQueue.main.async {
            let xOffset = CGFloat(self.initialPage) * self.bounds.width
            self.scrollView.setContentOffset(CGPoint(x: xOffset, y: 0), animated: false)
            self.pageControl.currentPage = self.initialPage
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupScrollView() {
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self
        addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        
        NotificationCenter.default.addObserver(
                self,
                selector: #selector(keyboardWillShow),
                name: UIResponder.keyboardWillShowNotification,
                object: nil
            )
            
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(keyboardWillHide),
                name: UIResponder.keyboardWillHideNotification,
                object: nil
            )
        
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    private func setupPages() {
        let uiviews: [UIView] = [viewContainerText, colorTextPickerView, UIView()]
        
        for i in 0..<numberOfPages {
            let page = uiviews[i]
            page.backgroundColor = .clear
            scrollView.addSubview(page)
            page.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                page.widthAnchor.constraint(equalTo: widthAnchor),
                page.heightAnchor.constraint(equalTo: heightAnchor),
                page.topAnchor.constraint(equalTo: scrollView.topAnchor),
                page.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
                page.leadingAnchor.constraint(equalTo: i == 0 ? scrollView.leadingAnchor : scrollView.subviews[i-1].trailingAnchor)
            ])
            
            if i == numberOfPages - 1 {
                page.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
            }
        }
    }
    
    private func setupPageControl() {
        pageControl.numberOfPages = numberOfPages
        pageControl.currentPage = 0
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        addSubview(pageControl)
        
        NSLayoutConstraint.activate([
            pageControl.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -10),
            pageControl.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }
    
    private func setupDeleteButton() {
            let sizeConfig = UIImage.SymbolConfiguration(pointSize: 28, weight: .bold)
            let palette = UIImage.SymbolConfiguration(paletteColors: [.white, .lightGray])
            let finalConfig = sizeConfig.applying(palette)
            let image = UIImage(systemName: "xmark.circle.fill", withConfiguration: finalConfig)
            
            deleteButton.setImage(image, for: .normal)
            deleteButton.translatesAutoresizingMaskIntoConstraints = false
            addSubview(deleteButton)
            
            NSLayoutConstraint.activate([
                deleteButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 0),
                deleteButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
                deleteButton.widthAnchor.constraint(equalToConstant: 30),
                deleteButton.heightAnchor.constraint(equalToConstant: 30)
            ])
            
            deleteButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        }
    private func setupTextView(){
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.font = UIFont.systemFont(ofSize: 14)
        textView.textColor = .white
        textView.backgroundColor = .clear
        textView.layer.cornerRadius = 8
        textView.isScrollEnabled = true   // có thể cuộn khi text dài
       
        let toolbar = UIToolbar()
            toolbar.sizeToFit()
            
            let doneButton = UIBarButtonItem(title: "Xong", style: .done, target: self, action: #selector(dismissKeyboard))
            let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            toolbar.items = [flexibleSpace, doneButton]   // nút nằm bên phải
            
            textView.inputAccessoryView = toolbar
        viewContainerText.addSubview(textView)

        NSLayoutConstraint.activate([
            textView.widthAnchor.constraint(equalTo: viewContainerText.widthAnchor,multiplier: 0.9),
            textView.topAnchor.constraint(equalTo: viewContainerText.topAnchor),
            textView.bottomAnchor.constraint(equalTo: viewContainerText.bottomAnchor),
            textView.leadingAnchor.constraint(equalTo: viewContainerText.leadingAnchor, constant: 10)
        ])
    }
    // MARK: - UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = Int(round(scrollView.contentOffset.x / bounds.width))
        pageControl.currentPage = pageIndex
    }
    
    @objc private func closeTapped() {
            self.removeFromSuperview() // xoá SlideView khi bấm nút
        }
    @objc private func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            let keyboardHeight = keyboardFrame.height
            // Đẩy view lên
            self.transform = CGAffineTransform(translationX: 0, y: -keyboardHeight/1.35)
        }
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        // Trả về vị trí ban đầu
        if let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
               let curveValue = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt {

                let options = UIView.AnimationOptions(rawValue: curveValue << 16)

                UIView.animate(withDuration: duration, delay: 0, options: options, animations: {
                    self.transform = .identity
                })
            }
    }
    @objc private func dismissKeyboard() {
        textView.resignFirstResponder() // ẩn bàn phím
    }
}

