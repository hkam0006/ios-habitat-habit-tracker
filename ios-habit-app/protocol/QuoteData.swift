//
//  QuoteData.swift
//  ios-habit-app
//
//  Created by Soodles . on 7/5/2023.
//

import Foundation

/**
 A class that represents Quote data object
 */
class QuoteData: NSObject, Decodable{
    // The quote text
    var quote: String?
    // The quote author
    var author: String?
    
    /**
     Coding Keys that map JSON keys to corresponding properties.
     */
    private enum RootKeys: String, CodingKey {
        case quote
        case author
    }
    
    /**
     Initializes a new instance of the `QuoteData` class by decoding the data from the given decoder.
     
     - Parameter decoder: The decoder to read data from.
     - Throws: An error if the decoding process fails.
     */
    required init(from decoder: Decoder) throws {
        let rootContainer = try decoder.container(keyedBy: RootKeys.self)
        quote = try rootContainer.decode(String.self, forKey: .quote)
        author = try rootContainer.decode(String.self, forKey: .author)
    }
}
