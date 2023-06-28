//
//  QuotePageViewController.swift
//  ios-habit-app
//
//  Created by Soodles . on 7/5/2023.
//

import UIKit

/**
 A View controller that queries an external API for inspirational quotes.
 */
class QuotePageViewController: UIViewController {
    // Outlets
    @IBOutlet weak var quoteLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var quoteButton: UIButton!
    // Activity loader
    var indicator = UIActivityIndicatorView()
    
    // Set up view controller on load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up activity indicator
        indicator.style = UIActivityIndicatorView.Style.large
        indicator.color = UIColor.label
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.layer.cornerRadius = 5
        // Adding indicator to view's sub views
        self.view.addSubview(indicator)
        NSLayoutConstraint.activate([
            // center horizontally
            indicator.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)
        ])
        
        // Do any additional setup after loading the view.
        quoteButton.configuration?.imagePadding = 0
        Task {
            // Start animating indicator
            indicator.startAnimating()
            if let quote = await getQuote(){
                // When quote information is retrieved stop animating indicator.
                indicator.stopAnimating()
                quoteLabel.text = quote.quote
                authorLabel.text = quote.author
            }
        }
    }
    
    /**
     Method that performs an asychronous call to the external API.
     
     - Returns: A `QuoteData` that encapsulates quote and quote author or returns `nil` if it receives an error when receiving quote data or decoder throws an error.
     */
    func getQuote() async -> QuoteData?{
        // Building URL
        var quoteURLComponents = URLComponents()
        quoteURLComponents.scheme = "https"
        quoteURLComponents.host = "api.api-ninjas.com"
        quoteURLComponents.path = "/v1/quotes"
        quoteURLComponents.queryItems = [URLQueryItem(name: "category", value: "inspirational")]
        guard let requestUrl = quoteURLComponents.url else {
            print("Invalid URL")
            return nil
        }
        // URL request with URL.
        var urlRequest = URLRequest(url: requestUrl)
        
        // Setting "X-Api-Key" to my API key.
        urlRequest.setValue("dAWe52YiXRHFjCHZXQdvPw==1IGLmS9vHO27T4W6", forHTTPHeaderField: "X-Api-Key")
        
        // Perform the API request
        do {
            // Get resposne from API
            let (data, _) = try await URLSession.shared.data(for: urlRequest)
            
            // Decoder for decoding JSON data.
            let decoder = JSONDecoder()
            
            // Try decode JSON response into `QuoteData` object,
            let quote = try decoder.decode([QuoteData].self, from: data)
            return quote[0]
        } catch let error{
            print(error)
            return nil
        }
    }
    
    /**
     Handles when the query API Button is tapped.
     
     - Parameter sender: The button that triggered the action.
     */
    @IBAction func queryAPIButton(_ sender: Any) {
        // Reset quote and author label text
        quoteLabel.text = ""
        authorLabel.text = ""
        // Start loading animation
        indicator.startAnimating()
        Task {
            if let quote = await getQuote(){
                quoteLabel.text = quote.quote
                authorLabel.text = quote.author
            }
            // Stop loading animation when the quote and author is retrieved and displayed.
            indicator.stopAnimating()
        }
        
    }

}
