//
//  Camera.swift
//  MovixVision
//
//  Created by rosteg on 01.10.2020.
//

import UIKit
import SafariServices

class MovieViewCell: UITableViewCell {

    @IBOutlet var posterImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!
    
    var movie: Movie?
    unowned var presenter: UIViewController?
    var imageTask: URLSessionDataTask?
    
    func setMovie(_ movie: Movie?) {
        guard let movie = movie else {
            return
        }
        self.movie = movie
        titleLabel.text = movie.name
        subtitleLabel.text = movie.description
        downloadImage()
    }
    
    @IBAction func openMovix(_ sender: Any) {
        guard
            let urlString = movie?.link,
            let url = URL(string: urlString),
            ["http", "https"].contains(url.scheme)
        else {
            return
        }
        let browser = SFSafariViewController(url: url)
        presenter?.present(browser, animated: true, completion: nil)
    }
    
    func downloadImage() {
        guard
            let movie = self.movie,
            let imageURL = URL(string: movie.imageSource)
        else {
            return
        }
        
        cancelImageDownload()
        let setImage: (Data?, URLResponse?, Error?) -> () = { [weak self] data, _, _ in
            DispatchQueue.main.async {
                guard let data = data, movie == self?.movie else {
                    return
                }
                self?.posterImageView.image = UIImage(data: data)
            }
        }
        imageTask = URLSession.shared.dataTask(with: imageURL, completionHandler: setImage)
        imageTask?.resume()
    }
    
    func cancelImageDownload() {
        imageTask?.cancel()
        imageTask = nil
    }
    
    override func prepareForReuse() {
        cancelImageDownload()
        movie = nil
    }
}

