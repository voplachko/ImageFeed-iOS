//
//  ImagesListViewController.swift
//  ImageFeed
//
//  Created by Vsevolod Oplachko on 05.02.2026.
//

import UIKit
import Kingfisher

protocol ImagesListViewControllerProtocol: AnyObject {
    func updateTableViewAnimated(oldCount: Int, newCount: Int)
    func showSingleImage(with url: URL?)
    func showBlockingProgressHUD()
    func dismissBlockingProgressHUD()
    func setLike(isLiked: Bool, at index: Int)
    func showLikeError()
}

final class ImagesListViewController: UIViewController {
    
    @IBOutlet private var tableView: UITableView!
    
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    private var presenter: ImagesListPresenterProtocol?
    private var selectedFullImageURL: URL?
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()

    func configure(_ presenter: ImagesListPresenterProtocol) {
        self.presenter = presenter
        presenter.view = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if presenter == nil {
            configure(ImagesListPresenter())
        }
        
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didUpdateImagesList),
            name: ImagesListService.didChangeNotification,
            object: nil
        )
        
        presenter?.viewDidLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            guard let viewController = segue.destination as? SingleImageViewController else {
                print("Invalid segue destination")
                return
            }
            
            viewController.fullImageURL = selectedFullImageURL
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    @objc private func didUpdateImagesList() {
        presenter?.updateTableViewAnimated()
    }
}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter?.numberOfRows() ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: ImagesListCell.reuseIdentifier,
            for: indexPath
        )
        
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        
        imageListCell.delegate = self
        configCell(for: imageListCell, with: indexPath)
        
        return imageListCell
    }
}

extension ImagesListViewController {
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        guard let photo = presenter?.photo(at: indexPath.row) else { return }
        let url = URL(string: photo.thumbImageURL)

        cell.setImageState(.loading)

        cell.cellImage.kf.setImage(with: url) { [weak self, weak cell] result in
            guard
                let self,
                let cell,
                let currentIndexPath = self.tableView.indexPath(for: cell),
                currentIndexPath == indexPath
            else { return }

            switch result {
            case .success(let value):
                cell.setImageState(.finished(value.image))
            case .failure:
                cell.setImageState(.error)
            }
        }

        if let date = photo.createdAt {
            cell.dateLabel.text = dateFormatter.string(from: date)
        } else {
            cell.dateLabel.text = ""
        }

        cell.setIsLiked(photo.isLiked)
    }
}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter?.didSelectPhoto(at: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        presenter?.heightForRow(at: indexPath.row, tableViewWidth: tableView.bounds.width) ?? 0
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        presenter?.didDisplayPhoto(at: indexPath.row)
    }
}

extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        presenter?.didTapLike(at: indexPath.row)
    }
}

extension ImagesListViewController: ImagesListViewControllerProtocol {
    func updateTableViewAnimated(oldCount: Int, newCount: Int) {
        tableView.performBatchUpdates {
            let indexPaths = (oldCount..<newCount).map { IndexPath(row: $0, section: 0) }
            tableView.insertRows(at: indexPaths, with: .automatic)
        } completion: { _ in }
    }

    func showSingleImage(with url: URL?) {
        selectedFullImageURL = url
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: nil)
    }

    func showBlockingProgressHUD() {
        UIBlockingProgressHUD.show()
    }

    func dismissBlockingProgressHUD() {
        UIBlockingProgressHUD.dismiss()
    }

    func setLike(isLiked: Bool, at index: Int) {
        let indexPath = IndexPath(row: index, section: 0)
        guard let cell = tableView.cellForRow(at: indexPath) as? ImagesListCell else { return }
        cell.setIsLiked(isLiked)
    }

    func showLikeError() {
        let alert = UIAlertController(
            title: "Не удалось поставить лайк",
            message: "Проверь подключение к интернету и попробуй ещё раз.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Ок", style: .default))
        present(alert, animated: true)
    }
}
