//
//  SingleImageViewController.swift
//  ImageFeed
//
//  Created by Vsevolod Oplachko on 09.02.2026.
//

import UIKit

final class SingleImageViewController: UIViewController {
    var image: UIImage? {
        didSet {
            guard isViewLoaded, let image else { return }
            
            imageView.image = image
            imageView.frame.size = image.size
            rescaleAndCenterImageInScrollView(image: image)
        }
    }
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var scrollView: UIScrollView!
    
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
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        
        scrollView.alwaysBounceVertical = true
        scrollView.alwaysBounceHorizontal = true

        guard let image else { return }
        imageView.image = image
        imageView.frame.size = image.size
        rescaleAndCenterImageInScrollView(image: image)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        recalcFitWidthScaleIfPossible()
        updateContentInsetForCentering()
    }
    
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        view.layoutIfNeeded()
        
        recalcFitWidthScaleIfPossible()
        
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        let scale = min(maxZoomScale, max(minZoomScale, min(hScale, vScale)))
        
        scrollView.setZoomScale(scale, animated: false)
        scrollView.layoutIfNeeded()
        
        updateContentInsetForCentering()
    }
    
    private func recalcFitWidthScaleIfPossible() {
        guard let image else { return }
        let visibleWidth = scrollView.bounds.width
        let imageWidth = image.size.width
        guard imageWidth > 0, visibleWidth > 0 else { return }
        
        fitWidthScale = visibleWidth / imageWidth
        fitWidthScale = min(fitWidthScale, scrollView.maximumZoomScale)
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
