import SoraUIKit
import SCard
import SnapKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let label = UILabel()
        label.text = "Start Sora Card"
        label.textColor = .blue
        label.isUserInteractionEnabled = true
        label.addTapGesture(with: { SoramitsuTapGestureRecognizer in
            self.showSoraCard()
        })

        view.addSubview(label)
        label.snp.makeConstraints {
            $0.center.equalToSuperview()
        }

        let resetLabel = UILabel()
        resetLabel.text = "reset token"
        resetLabel.textColor = .blue
        resetLabel.isUserInteractionEnabled = true
        resetLabel.addTapGesture(with: { SoramitsuTapGestureRecognizer in
            Task { await self.soraCard?.removeToken() }
        })

        view.addSubview(resetLabel)
        resetLabel.snp.makeConstraints {
            $0.top.equalTo(label.snp.bottom).offset(100)
            $0.centerX.equalToSuperview()
        }
    }

    private var soraCard: SCard?

    private var refreshBalanceTimer = Timer()
    func showSoraCard() {

        @SCStream var xorBalanceStream = SCStream<Decimal>(wrappedValue: Decimal(0))

        refreshBalanceTimer.invalidate()
        refreshBalanceTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            let balane = Decimal(UInt.random(in: 2500...5000))
            xorBalanceStream.wrappedValue = balane
        }

        let scConfig = SCard.Config(
            backendUrl: "https://backend.dev.sora-card.tachi.soramitsu.co.jp/",
            pwAuthDomain: "soracard.com",
            pwApiKey: "6974528a-ee11-4509-b549-a8d02c1aec0d",
            kycUrl: "https://kyc-test.soracard.com/mobile",
            kycUsername: "E7A6CB83-630E-4D24-88C5-18AAF96032A4",
            kycPassword: "75A55B7E-A18F-4498-9092-58C7D6BDB333",
            xOneEndpoint: "https://dev.x1ex.com/widgets/sdk.js",
            xOneId: "sprkwdgt-WYL6QBNC",
            environmentType: .test,
            themeMode: SoramitsuUI.shared.themeMode
        )

        soraCard = SCard(
            addressProvider: { "123" },
            config: scConfig,
            balanceStream: xorBalanceStream,
            onSwapController: { vc in
                print("show SwapController in \(vc)")
            }
        )

        soraCard?.start(in: self)
    }
}
