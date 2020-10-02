//
//  Movies.swift
//  MovixVision
//
//  Created by rosteg on 01.10.2020.
//

import Foundation

struct Movie: Codable, Equatable {

  let id: String
  let name: String
  let description: String
  let image: String
  let imageSource: String
  let subtitle: String?
  let rating: String
  let link: String

  enum CodingKeys: String, CodingKey {
    case id = "asset_id"
    case name = "asset_name"
    case description
    case image = "image_name"
    case imageSource = "image_source"
    case subtitle = "subtitle_name"
    case rating
    case link = "asset_link"
  }
}
