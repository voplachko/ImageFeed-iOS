//
//  ProfilePresenter.swift
//  ImageFeed
//
//  Created by Vsevolod Oplachko on 26.05.2026.
//

import Foundation

protocol ProfilePresenterProtocol: AnyObject {
    var view: ProfileViewControllerProtocol? { get set }
    
    func viewDidLoad()
    func didTapExitButton()
    func logout()
}

protocol ProfileServiceProtocol {
    var profile: Profile? { get }
}

protocol ProfileImageServiceProtocol {
    var avatarURL: String? { get }
}

protocol ProfileLogoutServiceProtocol {
    func logout()
}

extension ProfileService: ProfileServiceProtocol {}
extension ProfileImageService: ProfileImageServiceProtocol {}
extension ProfileLogoutService: ProfileLogoutServiceProtocol {}

final class ProfilePresenter: ProfilePresenterProtocol {
    weak var view: ProfileViewControllerProtocol?

    private let profileService: ProfileServiceProtocol
    private let profileImageService: ProfileImageServiceProtocol
    private let profileLogoutService: ProfileLogoutServiceProtocol

    init(
        profileService: ProfileServiceProtocol = ProfileService.shared,
        profileImageService: ProfileImageServiceProtocol = ProfileImageService.shared,
        profileLogoutService: ProfileLogoutServiceProtocol = ProfileLogoutService.shared
    ) {
        self.profileService = profileService
        self.profileImageService = profileImageService
        self.profileLogoutService = profileLogoutService
    }

    func viewDidLoad() {
        updateProfileDetails()
        view?.updateAvatar(with: profileImageService.avatarURL)
    }

    func didTapExitButton() {
        view?.showLogoutAlert()
    }

    func logout() {
        profileLogoutService.logout()
        view?.switchToSplashScreen()
    }

    private func updateProfileDetails() {
        guard let profile = profileService.profile else {
            return
        }

        view?.showProfileDetails(
            name: profile.name.isEmpty ? "Имя не указано" : profile.name,
            loginName: profile.loginName.isEmpty ? "@unknown_user" : profile.loginName,
            bio: (profile.bio?.isEmpty ?? true) ? "Профиль не заполнен" : profile.bio ?? "Профиль не заполнен"
        )
    }
}

