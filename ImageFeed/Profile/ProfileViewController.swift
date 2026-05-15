//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Vsevolod Oplachko on 09.02.2026.
//

import UIKit
import Kingfisher

final class ProfileViewController: UIViewController {
    
    // MARK: - UI
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(resource: .tyler))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 35
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let exitButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(
            UIImage(resource: .exitButton)
                .withRenderingMode(.alwaysOriginal),
            for: .normal
        )
        return button
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.font = .boldSystemFont(ofSize: 23)
        return label
    }()
    
    private let nicknameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .ypGray
        label.font = .systemFont(ofSize: 13, weight: .regular)
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.numberOfLines = 0
        return label
    }()
    
    private var profileImageServiceObserver: NSObjectProtocol?
    
    private var gradientViews: [AnimatedGradientView] = []
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
        addSubviews()
        setupConstraints()

        view.layoutIfNeeded()
        showLoadingAnimation()

        configureContent()
        setupActions()
        updateAvatar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        gradientViews.forEach {
            $0.startAnimation()
        }
    }
    
    deinit {
        if let profileImageServiceObserver {
            NotificationCenter.default.removeObserver(profileImageServiceObserver)
        }
    }
}

// MARK: - Setup

extension ProfileViewController {
    
    func configureView() {
        view.backgroundColor = .ypBlack
    }
    
    func addSubviews() {
        view.addSubview(profileImageView)
        view.addSubview(exitButton)
        view.addSubview(nameLabel)
        view.addSubview(nicknameLabel)
        view.addSubview(descriptionLabel)
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            profileImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            profileImageView.heightAnchor.constraint(equalToConstant: 70),
            profileImageView.widthAnchor.constraint(equalToConstant: 70),
            
            exitButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            exitButton.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor),
            exitButton.widthAnchor.constraint(equalToConstant: 24),
            exitButton.heightAnchor.constraint(equalToConstant: 24),
            
            nameLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 8),
            
            nicknameLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            nicknameLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            nicknameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            
            descriptionLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: nicknameLabel.bottomAnchor, constant: 8)
        ])
    }
    
    private func updateProfileDetails(profile: Profile) {
        nameLabel.text = profile.name.isEmpty
        ? "Имя не указано"
        : profile.name
        nicknameLabel.text = profile.loginName.isEmpty
        ? "@unknown_user"
        : profile.loginName
        descriptionLabel.text = (profile.bio?.isEmpty ?? true)
        ? "Профиль не заполнен"
        : profile.bio
    }
    
    func configureContent() {
        guard let profile = ProfileService.shared.profile else {
            print("[ProfileViewController] ❌ No profile data")
            return
        }
        
        updateProfileDetails(profile: profile)
    }
    
    func setupActions() {
        exitButton.addTarget(self, action: #selector(didTapExitButton), for: .touchUpInside)
    }
    
    private func updateAvatar() {
        guard
            let profileImageURL = ProfileImageService.shared.avatarURL,
            let imageUrl = URL(string: profileImageURL)
        else { return }
        
        print("imageUrl: \(imageUrl)")
        
        let placeholderImage = UIImage(systemName: "person.crop.circle")?
            .withTintColor(.lightGray, renderingMode: .alwaysOriginal)
            .withConfiguration(UIImage.SymbolConfiguration(pointSize: 70, weight: .regular, scale: .large))
        
        let processor = RoundCornerImageProcessor(cornerRadius: 35)
        profileImageView.kf.indicatorType = .activity
        profileImageView.kf.setImage(
            with: imageUrl,
            placeholder: placeholderImage,
            options: [
                .processor(processor),
                .scaleFactor(UIScreen.main.scale),
                .cacheOriginalImage,
                .forceRefresh
            ]) { result in
                
                self.hideLoadingAnimation()
                
                switch result {
                case .success(let value):
                    print(value.image)
                    print(value.cacheType)
                    print(value.source)
                case .failure(let error):
                    print(error)
                }
            }
    }
    
    @objc
    private func didTapExitButton() {
        let alert = UIAlertController(
            title: "Пока, пока!",
            message: "Уверены, что хотите выйти?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Да", style: .destructive) { _ in
            ProfileLogoutService.shared.logout()
            
            guard let window = UIApplication.shared.windows.first else {
                return
            }
            
            let splashViewController = SplashViewController()
            window.rootViewController = splashViewController
        })
        
        alert.addAction(UIAlertAction(title: "Нет", style: .cancel))
        
        present(alert, animated: true)
    }
    
    private func showLoadingAnimation() {
        addGradient(to: profileImageView, cornerRadius: 35)
        addGradient(to: nameLabel, cornerRadius: 8)
        addGradient(to: nicknameLabel, cornerRadius: 6)
        addGradient(to: descriptionLabel, cornerRadius: 6)
    }

    private func addGradient(to view: UIView, cornerRadius: CGFloat) {
        let gradientView = AnimatedGradientView(frame: view.bounds)
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        gradientView.layer.cornerRadius = cornerRadius

        view.addSubview(gradientView)

        NSLayoutConstraint.activate([
            gradientView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            gradientView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            gradientView.topAnchor.constraint(equalTo: view.topAnchor),
            gradientView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        gradientViews.append(gradientView)
    }

    private func hideLoadingAnimation() {
        gradientViews.forEach {
            $0.stopAnimation()
            $0.removeFromSuperview()
        }
        gradientViews.removeAll()
    }
}
