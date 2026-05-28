//
//  SingleImageViewController.swift
//  ImageFeed
//
//  Created by Vsevolod Oplachko on 09.02.2026.
//

import UIKit
import Kingfisher

final class SingleImageViewController: UIViewController {
    
    var fullImageURL: URL?
    
    @IBOutlet private weak var backButton: UIButton!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var scrollView: UIScrollView!
    
    private var image: UIImage?
    private var fitWidthScale: CGFloat = 0.1
    
    @IBAction private func didTapBackButton(_ sender: UIButton)  {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapShareButton(_ sender: Any) {
        guard let image else { return }
        let share = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil
        )
        present(share, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backButton.accessibilityIdentifier = "nav back button white"
        
        configureScrollView()
        loadImage()
    }
    
    private func configureScrollView() {
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        scrollView.alwaysBounceVertical = true
        scrollView.alwaysBounceHorizontal = true
        scrollView.delegate = self
    }
    
    private func loadImage() {
        guard let fullImageURL else { return }
        
        UIBlockingProgressHUD.show()
        
        imageView.kf.setImage(with: fullImageURL) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            
            guard let self else { return }
            
            switch result {
            case .success(let imageResult):
                let image = imageResult.image
                self.image = image
                
                self.imageView.image = image
                self.imageView.frame.size = image.size
                
                self.rescaleAndCenterImageInScrollView(image: image)
                
            case .failure:
                self.showError()
            }
        }
    }
    
    private func showError() {
        let alert = UIAlertController(
            title: "Что-то пошло не так",
            message: "Попробовать ещё раз?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Не надо", style: .cancel))
        
        alert.addAction(UIAlertAction(title: "Повторить", style: .default) { [weak self] _ in
            self?.loadImage()
        })
        
        present(alert, animated: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        recalcFitWidthScaleIfPossible()
        updateContentInsetForCentering()
    }
    
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        view.layoutIfNeeded()
        
        let visibleSize = scrollView.bounds.size
        let imageSize = image.size
        
        guard
            imageSize.width > 0,
            imageSize.height > 0,
            visibleSize.width > 0,
            visibleSize.height > 0
        else {
            return
        }
        
        recalcFitWidthScaleIfPossible()
        
        let hScale = visibleSize.width / imageSize.width
        let vScale = visibleSize.height / imageSize.height
        
        let scale = min(
            scrollView.maximumZoomScale,
            max(scrollView.minimumZoomScale, min(hScale, vScale))
        )
        
        scrollView.setZoomScale(scale, animated: false)
        scrollView.layoutIfNeeded()
        
        updateContentInsetForCentering()
    }
    
    private func recalcFitWidthScaleIfPossible() {
        guard
            let image,
            image.size.width > 0,
            scrollView.bounds.width > 0
        else {
            fitWidthScale = scrollView.minimumZoomScale
            return
        }
        
        let visibleWidth = scrollView.bounds.width
        let imageWidth = image.size.width
        
        let scale = visibleWidth / imageWidth
        fitWidthScale = min(scale, scrollView.maximumZoomScale)
    }
    
    private func updateContentInsetForCentering() {
        let boundsSize = scrollView.bounds.size
        let contentSize = scrollView.contentSize
        
        let horizontalInset = max(0, (boundsSize.width - contentSize.width) / 2)
        let verticalInset = max(0, (boundsSize.height - contentSize.height) / 2)
        
        scrollView.contentInset = UIEdgeInsets(
            top: verticalInset,
            left: horizontalInset,
            bottom: verticalInset,
            right: horizontalInset
        )
    }
}

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        updateContentInsetForCentering()
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        if scale < fitWidthScale {
            scrollView.setZoomScale(fitWidthScale, animated: true)
        } else {
            updateContentInsetForCentering()
        }
    }
}
