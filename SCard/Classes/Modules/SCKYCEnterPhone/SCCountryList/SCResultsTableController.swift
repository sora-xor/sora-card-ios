import UIKit

class SCResultsTableController: UITableViewController {

    let tableViewCellIdentifier = "cellID"

    var filteredCountries: [SCCountry] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(SCCountryCell.self, forCellReuseIdentifier: tableViewCellIdentifier)
    }

    // MARK: - UITableViewDataSource

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredCountries.count
    }

    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: tableViewCellIdentifier, for: indexPath) as? SCCountryCell
        let country = filteredCountries[indexPath.row]
        cell?.icon.image = country.flag
        cell?.title.text = country.name
        // TODO: Localize cell?.subtitle.text = country.name
        cell?.value.text = country.dialCode
        return cell ?? .init()
    }
}
