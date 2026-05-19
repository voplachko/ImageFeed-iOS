//
//  AnimatedGradientView.swift
//  ImageFeed
//
//  Created by Vsevolod Oplachko on 15.05.2026.
//

import UIKit

final class AnimatedGradientView: UIView {
    private let gradientLayer = CAGradientLayer()
    private var isAnimating = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGradient()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupGradient()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        gradientLayer.frame = bounds
        gradientLayer.cornerRadius = layer.cornerRadius

        if !isAnimating {
            startAnimation()
        }
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()

        if window != nil {
            startAnimation()
        }
    }

    private func setupGradient() {
        isUserInteractionEnabled = false
        clipsToBounds = true

        gradientLayer.locations = [0, 0.1, 0.3]
        gradientLayer.colors = [
            UIColor(red: 0.682, green: 0.686, blue: 0.706, alpha: 1).cgColor,
            UIColor(red: 0.531, green: 0.533, blue: 0.553, alpha: 1).cgColor,
            UIColor(red: 0.431, green: 0.433, blue: 0.453, alpha: 1).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)

        layer.addSublayer(gradientLayer)
    }

    func startAnimation() {
        gradientLayer.removeAnimation(forKey: "locationsChange")

        let animation = CABasicAnimation(keyPath: "locations")
        animation.duration = 1
        animation.repeatCount = .infinity
        animation.fromValue = [-1, -0.5, 0]
        animation.toValue = [1, 1.5, 2]
        animation.isRemovedOnCompletion = false

        gradientLayer.add(animation, forKey: "locationsChange")
    }

    func stopAnimation() {
        isAnimating = false
        gradientLayer.removeAllAnimations()
    }
}
