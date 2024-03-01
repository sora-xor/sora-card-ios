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
        @SCStream var xorBalanceStream = SCStream<Decimal>(wrappedValue: Decimal(0))

        refreshBalanceTimer.invalidate()
        refreshBalanceTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            xorBalanceStream.wrappedValue = Decimal(UInt.random(in: 2500...500000))
        }

        SoramitsuUI.shared.themeMode = .manual(.dark)

        /// Set BundleID: co.jp.soramitsu.sora.test fot TEST recaptchaKey
        let scConfig = SCard.Config(
            appStoreUrl: "https://apps.apple.com/us/app/sora-wallet-polkaswap/id1457566711",
            backendUrl: "https://backend.dev.sora-card.tachi.soramitsu.co.jp/",
            pwAuthDomain: "soracard.com",
            pwApiKey: "6974528a-ee11-4509-b549-a8d02c1aec0d",
            appPlatformId: "6CB2884B-17CA-4F9F-800C-9C89646D773D",
            recaptchaKey: "6Lftc1QpAAAAAMRvMZFoqR9I4SI-yRZ8AF-cA40F",
            kycUrl: "https://kyc-test.soracard.com/mobile",
            kycUsername: "E7A6CB83-630E-4D24-88C5-18AAF96032A4",
            kycPassword: "75A55B7E-A18F-4498-9092-58C7D6BDB333",
            xOneEndpoint: "https://dev.x1ex.com/widgets/sdk.js",
            xOneId: "sprkwdgt-WYL6QBNC",
            environmentType: .test,
            themeMode: SoramitsuUI.shared.themeMode
        )

        let soraCard = SCard(
            addressProvider: { "123" },
            config: scConfig,
            balanceStream: xorBalanceStream,
            onReceiveController: { vc in
                print("show onReceiveController in \(vc)")
            },
            onSwapController: { vc in
                print("show SwapController in \(vc)")
            }
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
