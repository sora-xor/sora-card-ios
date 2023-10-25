import UIKit

extension SCCountryList: UISearchResultsUpdating {

    func updateSearchResults(for searchController: UISearchController) {
        let searchResults = countries
        let whitespaceCharacterSet = CharacterSet.whitespaces
        let searchString = searchController.searchBar.text!
            .trimmingCharacters(in: whitespaceCharacterSet)
            .lowercased()

        let filteredResults = searchResults.filter {
            $0.name.lowercased().contains(searchString) ||
            $0.code.lowercased().contains(searchString)
        }

        if let resultsController = searchController.searchResultsController as? SCResultsTableController {
            resultsController.filteredCountries = filteredResults
            resultsController.tableView.reloadData()
        }
    }
}
