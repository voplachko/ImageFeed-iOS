//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Vsevolod Oplachko on 09.02.2026.
//

import UIKit
import Kingfisher

final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    
    weak var delegate: ImagesListCellDelegate?
    
    @IBOutlet var cellImage: UIImageView!
    @IBOutlet var likeButton: UIButton!
    @IBOutlet var dateLabel: UILabel!
    
    private var gradientView: AnimatedGradientView?
    
    override func prepareForReuse() {
        super.prepareForReuse()

        cellImage.kf.cancelDownloadTask()
        cellImage.image = nil
        dateLabel.text = nil
        hideGradient()
    }
    
    @IBAction private func likeButtonClicked(_ sender: UIButton) {
        delegate?.imageListCellDidTapLike(self)
    }
    
    func setIsLiked(_ isLiked: Bool) {
        let image = UIImage(
            resource: isLiked ? .likeButtonOn : .likeButtonOff
        )
        
        likeButton.setImage(image, for: .normal)
    }
    
    func setImageState(_ state: FeedCellImageState) {
        switch state {
        case .loading:
            cellImage.image = nil
            showGradient()
            
        case .error:
            hideGradient()
            let placeholderImage = UIImage(systemName: "person.crop.circle")?
                .withTintColor(.lightGray, renderingMode: .alwaysOriginal)
                .withConfiguration(UIImage.SymbolConfiguration(pointSize: 70, weight: .regular, scale: .large))
            cellImage.image = placeholderImage
            
        case .finished(let image):
            hideGradient()
            cellImage.image = image
        }
    }
    
    private func showGradient() {
        hideGradient()
        
        let gradientView = AnimatedGradientView()
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        gradientView.layer.cornerRadius = cellImage.layer.cornerRadius
        gradientView.clipsToBounds = true
        
        cellImage.addSubview(gradientView)
        
        NSLayoutConstraint.activate([
            gradientView.leadingAnchor.constraint(equalTo: cellImage.leadingAnchor),
            gradientView.trailingAnchor.constraint(equalTo: cellImage.trailingAnchor),
            gradientView.topAnchor.constraint(equalTo: cellImage.topAnchor),
            gradientView.bottomAnchor.constraint(equalTo: cellImage.bottomAnchor)
        ])
        
        self.gradientView = gradientView
    }
    
    private func hideGradient() {
        gradientView?.stopAnimation()
        gradientView?.removeFromSuperview()
        gradientView = nil
    }
}
