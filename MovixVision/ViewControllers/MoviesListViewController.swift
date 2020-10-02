//
//  MoviesListViewController.swift
//  MovixVision
//
//  Created by rosteg on 02.10.2020.
//

import UIKit

class MoviesListViewController: DismissingModalViewController {
    
    static func build(movieService: MovieService, indices: [Int], onDismiss: (() -> ())?) -> MoviesListViewController? {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let id = "MoviesListViewController"
        let vc = storyboard.instantiateViewController(withIdentifier: id) as? MoviesListViewController
        vc?.movieService = movieService
        vc?.indices = indices
        vc?.onDismiss = onDismiss
        return vc
    }
    
    private var movieService: MovieService!
    private var indices: [Int] = []
    
    @IBOutlet var headerLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setHeaderLabel()
    }
    
    func setHeaderLabel() {
        let formatString = NSLocalizedString("Найдено фильмов: %d", comment: "header")
        headerLabel.text = String(format: formatString, indices.count)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

extension MoviesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return indices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieViewCell", for: indexPath) as! MovieViewCell
        cell.presenter = self
        cell.setMovie(movieService.movie(at: indices[indexPath.row]))
        return cell
    }
}
