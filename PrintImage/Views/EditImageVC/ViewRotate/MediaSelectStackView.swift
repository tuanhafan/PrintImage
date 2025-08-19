//
//  TopView.swift
//  PrintImage
//
//  Created by Alex Tran on 5/8/25.
//

import UIKit

class MediaSelectStackView: UIStackView {

    // MARK: - Button Callbacks
    var onPaletteTapped: (() -> Void)?
    var onSliderTapped: (() -> Void)?
    var onGridTapped: ((_ isGrid:Bool) -> Void)?

    private let paintpaletteBtn = ButtonIcon.createIconButton(systemName: "paintpalette.fill")
    private let squareshapeBtn = ButtonIcon.createIconButton(systemName: "squareshape.split.3x3")
    private let sliderBtn = ButtonIcon.createIconButton(systemName: "slider.horizontal.3")

    
    private var isgridVisible: Bool = false {
        didSet {
            squareshapeBtn.tintColor = isgridVisible ? .white : .lightGray
        }
    }
    
    init() {
        super.init(frame: .zero)
        setupStackView()
        setupButtons()
    }

    required init(coder: NSCoder) {
        super.init(coder: coder)
        setupStackView()
        setupButtons()
    }

    private func setupStackView() {
        axis = .horizontal
        alignment = .center
        distribution = .equalSpacing
        spacing = ResponsiveLayout.bottomSpacing()
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .darkGray

        isLayoutMarginsRelativeArrangement = true
        layoutMargins = UIEdgeInsets(
            top: 5,
            left: ResponsiveLayout.horizontalMargin(),
            bottom: 5,
            right: ResponsiveLayout.horizontalMargin()
        )
    }

    private func setupButtons() {
        squareshapeBtn.tintColor = .lightGray

        paintpaletteBtn.addTarget(self, action: #selector(paletteTapped), for: .touchUpInside)
        squareshapeBtn.addTarget(self, action: #selector(gridTapped), for: .touchUpInside)
        sliderBtn.addTarget(self, action: #selector(sliderTapped), for: .touchUpInside)

        [paintpaletteBtn, squareshapeBtn, sliderBtn].forEach { btn in
            btn.widthAnchor.constraint(equalToConstant: ResponsiveLayout.buttonSize()).isActive = true
            btn.heightAnchor.constraint(equalToConstant: ResponsiveLayout.buttonSize()).isActive = true
            addArrangedSubview(btn)
        }
    }

    @objc private func paletteTapped() {
        onPaletteTapped?()
    }

    @objc private func sliderTapped() {
        onSliderTapped?()
    }

    @objc private func gridTapped() {
        isgridVisible = !isgridVisible
        onGridTapped?(isgridVisible)
    }
}

