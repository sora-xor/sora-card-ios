import SoraUIKit
import SCard
import SnapKit

class ViewController: UIViewController {

    private let scardCellId = "SCCardCell"
    private lazy var table: UITableView = {
        let view = UITableView()
        view.register(SCCardCell.self, forCellReuseIdentifier: scardCellId)
        view.refreshControl = .init()
        view.refreshControl?.addTarget(self, action: #selector(onRefresh), for: .valueChanged)
        return view
    }()

    private var refreshBalanceTimer = Timer()

    private lazy var soraCard: SCard = initSCard()
    private lazy var scardItem: SCCardItem = {
        SCCardItem(service: soraCard) {
            print("TODO: close scard")
        } onCard: { [weak self] in
            self?.showSoraCard()
        }
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        SoramitsuUI.shared.themeMode = .manual(.dark)

        table.delegate = self
        table.dataSource = self

        view.addSubview(table)
        table.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    private func showSoraCard() {
        soraCard.start(in: self)
    }

    private func initSCard() -> SCard {
        var xorBalanceStream = SCStream(wrappedValue: Decimal(0))

        refreshBalanceTimer.invalidate()
        refreshBalanceTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            xorBalanceStream.wrappedValue = Decimal(UInt.random(in: 2500...500000))
        }

        // Dev BundleID: co.jp.soramitsu.sora.dev
        let local = SCard.Config(
            appStoreUrl: "",
            backendUrl: "",
            pwAuthDomain: "",
            pwApiKey: "",
            appPlatformId: "",
            recaptchaKey: "",
            kycUrl: "",
            kycUsername: "",
            kycPassword: "",
            xOneEndpoint: "",
            xOneId: "",
            environmentType: .test,
            themeMode: SoramitsuUI.shared.themeMode
        )

        let soraCard = SCard(
            addressProvider: { "123" },
            config: local,
            balanceStream: xorBalanceStream,
            onReceiveController: { vc in
                print("show onReceiveController in \(vc)")
            },
            onSwapController: { vc in
                print("show SwapController in \(vc)")
            },
            logLevels: .info
        )
        return soraCard
    }

    @objc func onRefresh(refreshControl: UIRefreshControl) {
        table.reloadData()
        refreshControl.endRefreshing()
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        2
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: scardCellId) ?? SCCardCell()
            guard let scardCell = cell as? SoramitsuTableViewCellProtocol else { return cell }
            scardCell.set(item: scardItem, context: nil)
            return cell

        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "LogoutCell") ??
                UITableViewCell(style: .subtitle, reuseIdentifier: "LogoutCell")
            cell.textLabel?.text = soraCard.isUserSignIn ? "Logout" : "Logouted"
            return cell
        default:
            return .init()
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 1:
            soraCard.logout()
            let cell = tableView.cellForRow(at: indexPath)
            cell?.isSelected = false
            cell?.textLabel?.text = soraCard.isUserSignIn ? "Logout" : "Logouted"
        default:
            return
        }
    }
}
