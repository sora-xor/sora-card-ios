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
            let balane = Decimal(UInt.random(in: 1000...3000))
            xorBalanceStream.wrappedValue = balane
        }

        let scConfig = SCard.Config(
            backendUrl: "",
            pwAuthDomain: "",
            pwApiKey: "",
            kycUrl: "",
            kycUsername: "",
            kycPassword: "",
            xOneEndpoint: "",
            xOneId: "",
            environmentType: .test,
            themeMode: .manual(.dark)
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
