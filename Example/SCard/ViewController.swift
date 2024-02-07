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
            self.soraCard?.logout()
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
            xorBalanceStream.wrappedValue = Decimal(UInt.random(in: 2500...500000))
        }

        SoramitsuUI.shared.themeMode = .manual(.dark)

        /// Set BundleID: co.jp.soramitsu.sora.test fot TEST recaptchaKey
        let scConfig = SCard.Config(
            appStoreUrl: "https://apps.apple.com/us/app/sora-wallet-polkaswap/id1457566711",
            backendUrl: "https://backend.dev.sora-card.tachi.soramitsu.co.jp/",
            pwAuthDomain: "soracard.com",
            pwApiKey: "",
            appPlatformId: "",
            recaptchaKey: "",
            kycUrl: "https://kyc-test.soracard.com/mobile",
            kycUsername: "",
            kycPassword: "",
            xOneEndpoint: "https://dev.x1ex.com/widgets/sdk.js",
            xOneId: "sprkwdgt-WYL6QBNC",
            environmentType: .test,
            themeMode: SoramitsuUI.shared.themeMode
        )

        soraCard = SCard(
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

        soraCard?.start(in: self)
    }
}
