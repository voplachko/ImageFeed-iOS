//
//  AuthViewController.swift
//  ImageFeed
//
//  Created by Vsevolod Oplachko on 18.02.2026.
//

import UIKit
import ProgressHUD

final class AuthViewController: UIViewController {

    // MARK: - UI

    private let logoImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(resource: .authScreenLogo))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Войти", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .bold)
        button.setTitleColor(UIColor(resource: .ypBlack), for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 16
        button.accessibilityIdentifier = "Authenticate"
        return button
    }()

    // MARK: - Private Properties

    private let oauth2Service = OAuth2Service.shared

    // MARK: - Public Properties

    weak var delegate: AuthViewControllerDelegate?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        configureView()
        configureBackButton()
        addSubviews()
        setupConstraints()
        setupActions()
    }
}

// MARK: - Setup

extension AuthViewController {

    private func configureView() {
        view.backgroundColor = UIColor(resource: .ypBlack)
    }

    private func addSubviews() {
        view.addSubview(logoImageView)
        view.addSubview(loginButton)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            loginButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            loginButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            loginButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -90),
            loginButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }

    private func setupActions() {
        loginButton.addTarget(self, action: #selector(didTapLoginButton), for: .touchUpInside)
    }

    private func configureBackButton() {
        navigationController?.navigationBar.backIndicatorImage = UIImage(resource: .navBackButton)
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(resource: .navBackButton)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = UIColor(resource: .ypBlack)
    }

    @objc
    private func didTapLoginButton() {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)

        guard let webViewViewController = storyboard.instantiateViewController(
            withIdentifier: "WebViewViewController"
        ) as? WebViewViewController else {
            assertionFailure("Unable to instantiate WebViewViewController")
            return
        }

        let authHelper = AuthHelper()
        let webViewPresenter = WebViewPresenter(authHelper: authHelper)
        webViewViewController.presenter = webViewPresenter
        webViewPresenter.view = webViewViewController
        webViewViewController.delegate = self
        webViewViewController.modalPresentationStyle = .pageSheet

        present(webViewViewController, animated: true)
    }
}

// MARK: - WebViewViewControllerDelegate

extension AuthViewController: WebViewViewControllerDelegate {

    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        vc.dismiss(animated: true)

        UIBlockingProgressHUD.show()

        oauth2Service.fetchOAuthToken(code: code) { [weak self] result in
            UIBlockingProgressHUD.dismiss()

            guard let self else { return }

            switch result {
            case .success:
                self.delegate?.didAuthenticate(self)

            case .failure:
                let alert = UIAlertController(
                    title: "Что-то пошло не так",
                    message: "Не удалось войти в систему",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "Ок", style: .default))
                self.present(alert, animated: true)
            }
        }
    }

    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        vc.dismiss(animated: true)
    }
}
