//
//  CurvesAdjustmentView.swift
//  PrintImage
//
//  Created by Alex Tran on 16/8/25.
//

import Foundation
import UIKit

final class CurvesAdjustmentView: UIView {
        
       private let curvesContainer = UIView()
        private let curvesEditor = CurvesEditorView()
        private let controlContainer = UIView()
        private let backgroundView = UIView()
        private let resetButton: UIButton = {
            let btn = UIButton(type: .system)
            let config = UIImage.SymbolConfiguration(pointSize: 30, weight: .regular)
            let image = UIImage(systemName: "arrow.counterclockwise", withConfiguration: config)
            btn.setImage(image, for: .normal)
            btn.tintColor = .white
            return btn
        }()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            backgroundView.translatesAutoresizingMaskIntoConstraints = false
            backgroundView.backgroundColor = .white
            backgroundView.alpha = 0.5
            addSubview(backgroundView)
            self.sendSubviewToBack(backgroundView)
            NSLayoutConstraint.activate([
                backgroundView.leadingAnchor.constraint(equalTo: leadingAnchor),
                backgroundView.topAnchor.constraint(equalTo: topAnchor),
                backgroundView.bottomAnchor.constraint(equalTo: bottomAnchor),
                backgroundView.trailingAnchor.constraint(equalTo: trailingAnchor),
            ])
            
            // --- Curves container ---
            curvesContainer.backgroundColor = .clear
            curvesContainer.layer.borderColor = UIColor.black.cgColor
            curvesContainer.layer.borderWidth = 0.5
            addSubview(curvesContainer)
            curvesContainer.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                curvesContainer.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 25),
                curvesContainer.topAnchor.constraint(equalTo: topAnchor,constant: 10),
                curvesContainer.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -25),
                curvesContainer.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.75) // 75% chiều rộng
            ])
            
            curvesContainer.addSubview(curvesEditor)
            curvesEditor.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                curvesEditor.leadingAnchor.constraint(equalTo: curvesContainer.leadingAnchor),
                curvesEditor.trailingAnchor.constraint(equalTo: curvesContainer.trailingAnchor),
                curvesEditor.topAnchor.constraint(equalTo: curvesContainer.topAnchor),
                curvesEditor.bottomAnchor.constraint(equalTo: curvesContainer.bottomAnchor)
            ])
            
            // --- Control container ---
            controlContainer.backgroundColor = .clear
            addSubview(controlContainer)
            controlContainer.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                controlContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
                controlContainer.topAnchor.constraint(equalTo: topAnchor),
                controlContainer.bottomAnchor.constraint(equalTo: bottomAnchor),
                controlContainer.leadingAnchor.constraint(equalTo: curvesContainer.trailingAnchor)
            ])
            
            controlContainer.addSubview(resetButton)
            resetButton.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                resetButton.centerXAnchor.constraint(equalTo: controlContainer.centerXAnchor),
                resetButton.centerYAnchor.constraint(equalTo: controlContainer.centerYAnchor),
            ])
            
            resetButton.addTarget(self, action: #selector(didTapReset), for: .touchUpInside)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        @objc private func didTapReset() {
            curvesEditor.resetPoints()
        }
        
        // Expose callback
        var onCurveChanged: (([CGPoint]) -> Void)? {
            get { curvesEditor.onCurveChanged }
            set { curvesEditor.onCurveChanged = newValue }
        }
    }
