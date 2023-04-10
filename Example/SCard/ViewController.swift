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
            self.soraCard?.resetState()
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

        let (balanceStream, balanceContinuation) = AsyncStream<Decimal>.streamWithContinuation()

        refreshBalanceTimer.invalidate()
        refreshBalanceTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            balanceContinuation.yield(Decimal(UInt.random(in: 0...150)))
        }

        let scConfig = SCard.Config(
            backendUrl: "",
            pwAuthDomain: "",
            pwApiKey: "",
            kycUrl: "",
            kycUsername: "",
            kycPassword: "",
            environmentType: .test,
            themeMode: .manual(.dark)
        )

        soraCard = SCard(
            address: "123",
            config: scConfig,
            balanceStream: balanceStream,
            onSwapController: { vc in
                print("TODO: show SwapController in \(vc)")
            }
        )

        soraCard?.start(in: self)
    }
}
