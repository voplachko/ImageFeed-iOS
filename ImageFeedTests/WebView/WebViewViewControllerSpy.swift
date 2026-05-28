//
//  WebViewViewControllerSpy.swift
//  ImageFeed
//
//  Created by Vsevolod Oplachko on 26.05.2026.
//

@testable import ImageFeed
import Foundation

final class WebViewViewControllerSpy: NSObject, WebViewViewControllerProtocol {
    var presenter: WebViewPresenterProtocol?

    var loadRequestCalled = false

    func load(request: URLRequest) {
        loadRequestCalled = true
    }

    func setProgressValue(_ newValue: Float) {}

    func setProgressHidden(_ isHidden: Bool) {}
}
