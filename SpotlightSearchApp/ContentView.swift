//
//  ContentView.swift
//  SpotlightSearchApp
//
//  Created by Денис Трясунов on 29.04.2023.
//

import CoreSpotlight
import SwiftUI

struct ContentView: View {

    @State private var searchText = ""

    @State private var searchResults = [CSSearchableItem]()
    @State private var searchQuery: CSSearchQuery?

    var body: some View {
        VStack {
            Button("Add sample data to SL", action: addTestDataToSpotlight)

            TextField("Search SL", text: $searchText)
                .textFieldStyle(.roundedBorder)
                .onChange(of: searchText) { _ in
                    searchSpotlight()
                }

            List(searchResults, id: \.uniqueIdentifier) { result in
                Text(result.attributeSet.title ?? "n/a")
            }
        }
        .padding()
    }

    func addTestDataToSpotlight() {
        let titles = ["Test data one", "Second piece of data to test", "Hello, world!", "Goodnight, Earth and Moon!"]

        for title in titles {
            let attributeSet = CSSearchableItemAttributeSet(contentType: .text)
            attributeSet.title = title

            let searchableItem = CSSearchableItem(
                uniqueIdentifier: title,
                domainIdentifier: nil,
                attributeSet: attributeSet
            )

            CSSearchableIndex.default().indexSearchableItems([searchableItem])
        }
    }

    func searchSpotlight() {
        // first, cancel any existing queries:
        searchQuery?.cancel()

        var matches = [CSSearchableItem]()

        let queryString = "title == \"*\(searchText)*\"c"
        searchQuery = CSSearchQuery(queryString: queryString, attributes: ["title"])

        searchQuery?.foundItemsHandler = { items in
            matches.append(contentsOf: items)
        }

        searchQuery?.completionHandler = { _ in
            DispatchQueue.main.async {
                self.searchResults = matches
            }
        }

        searchQuery?.start()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
