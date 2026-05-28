//
//  ProfilePresenterSpy.swift
//  ImageFeed
//
//  Created by Vsevolod Oplachko on 26.05.2026.
//

@testable import ImageFeed
import Foundation

final class ProfilePresenterSpy: ProfilePresenterProtocol {
    var view: ProfileViewControllerProtocol?
    var viewDidLoadCalled: Bool = false
    var didTapExitButtonCalled: Bool = false
    var didLogoutCalled: Bool = false

    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func didTapExitButton() {
        didTapExitButtonCalled = true
    }
    
    func logout() {
        didLogoutCalled = true
    }
}
