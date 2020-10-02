//
//  Movies.swift
//  MovixVision
//
//  Created by rosteg on 01.10.2020.
//

import Foundation

class MoviesDB {
  let movies: [Movie]

  convenience init() {
    let bundledMetadataPath = Bundle.main.path(forResource: "movies", ofType: "json")!
    self.init(metadataPath: bundledMetadataPath)!
  }

  init?(metadataPath: String) {
    guard
      let data = try? Data(contentsOf: URL(fileURLWithPath: metadataPath)),
      let movies = try? JSONDecoder().decode([Movie].self, from: data)
    else {
      return nil
    }

    self.movies = movies
  }

  subscript(index: Int) -> Movie? {
    return movies[index]
  }
}
