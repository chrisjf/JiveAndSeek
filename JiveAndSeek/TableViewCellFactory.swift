//
//  TableViewCellFactory.swift
//  JiveAndSeek
//
//  Created by Christopher Forbes on 2021-06-03.
//

import UIKit

class TableViewCellFactory {

    func cellIdentifier(forRowAt indexPath: IndexPath, in tableView: UITableView) -> String {
        return String(describing: AlbumCell.self)
    }

    func registerCells(for tableView: UITableView) {
        let identifier = String(describing: AlbumCell.self)
        let nib = UINib(nibName: identifier, bundle: Bundle.main)
        tableView.register(nib, forCellReuseIdentifier: identifier)
    }

    func cell(for indexPath: IndexPath, item: Any?, tableView: UITableView) -> UITableViewCell {
        let cellIdentifier = cellIdentifier(forRowAt: indexPath, in: tableView)
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        prepare(cell, with: item, forRowAt: indexPath)
        return cell
    }

    // MARK: Helpers

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = .autoupdatingCurrent
        formatter.dateStyle = .short
        return formatter
    }()

    private func prepare(_ cell: UITableViewCell, with item: Any?, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? AlbumCell,
              let album = item as? Album else {
            return
        }

        cell.nameLabel?.text = album.name

        if let releaseDate = album.releaseDate {
            cell.releaseDateLabel?.text = dateFormatter.string(from: releaseDate)
        } else {
            cell.releaseDateLabel?.text = ""
        }

        if let artwork = album.artwork {
            cell.artworkImageView?.image = artwork
        } else {
            cell.artworkImageView?.image = UIImage(systemName: "opticaldisc")?.withTintColor(.gray, renderingMode: .alwaysOriginal)
        }
    }

}
