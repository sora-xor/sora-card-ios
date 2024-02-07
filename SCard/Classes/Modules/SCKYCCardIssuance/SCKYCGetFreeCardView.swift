import UIKit
import SoraUIKit

class SCKYCGetFreeCardView: UIView {

    var onButton: (() -> Void)?

    private var containerView: SoramitsuStackView = {
        var view = SoramitsuStackView()
        view.sora.backgroundColor = .bgSurface
        view.sora.axis = .vertical
        view.sora.shadow = .default
        view.spacing = 16
        view.sora.cornerRadius = .medium
        view.sora.distribution = .fill
        view.layoutMargins = UIEdgeInsets(top: 16, left: 24, bottom: 16, right: 24)
        view.isLayoutMarginsRelativeArrangement = true
        return view
    }()

    private let titleLabel: SoramitsuLabel = {
        let label = SoramitsuLabel()
        label.sora.font = FontType.displayM
        label.sora.textColor = .fgPrimary
        label.sora.numberOfLines = 0
        label.sora.text = R.string.soraCard.detailsFreeCardIssuance(preferredLanguages: .currentLocale)
        return label
    }()

    private let subtitleLabel: SoramitsuLabel = {
        let label = SoramitsuLabel()
        label.sora.font = FontType.paragraphM
        label.sora.textColor = .fgPrimary
        label.sora.numberOfLines = 0
        label.sora.text = R.string.soraCard.cardIssuanceScreenFreeCardDescription(
            String(SCard.minXorAmount),
            preferredLanguages: .currentLocale
        )
        return label
    }()

    private let balanceProgressView = SCBalanceProgressView()

    private lazy var button: SoramitsuButton = {
        let button = SoramitsuButton(size: .large, type: .filled(.secondary))
        button.sora.addHandler(for: .touchUpInside) { [weak self] in
            self?.button.isEnabled = false
            self?.onButton?()
            self?.button.isEnabled = true
        }
        let title = R.string.soraCard.detailsIssueCard(preferredLanguages: .currentLocale)
        button.sora.attributedText = SoramitsuTextItem(
            text: title,
            fontData: FontType.buttonM,
            textColor: .fgInverted,
            alignment: .center
        )

        button.sora.cornerRadius = .custom(28)
        button.isEnabled = false
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupInitialLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(percentage: Float, needMoreXor: Decimal, needMoreXorInFiat: Decimal, isButtonEnabled: Bool) {

        balanceProgressView.configure(
            progressPercentage: percentage,
            needMoreXor: needMoreXor,
            needMoreXorInFiat: needMoreXorInFiat
        )

        let title: String

        if percentage >= SCKYCCardIssuanceViewModel.minAmountOfEuroProcentage {
            title = R.string.soraCard.detailsIssueCard(preferredLanguages: .currentLocale)
        } else {
            let needMoreXorText = NumberFormatter.polkaswapBalance.stringFromDecimal(needMoreXor) ?? ""
            title = R.string.soraCard.cardIssuanceScreenFreeCardGetXor(needMoreXorText, preferredLanguages: .currentLocale)
        }

        button.sora.attributedText = SoramitsuTextItem(
            text: title,
            fontData: FontType.buttonM,
            textColor: .fgInverted,
            alignment: .center
        )

        button.isEnabled = isButtonEnabled

        if isButtonEnabled {
            subtitleLabel.sora.text = R.string.soraCard.cardIssuanceScreenFreeCardDescription(
                String(SCard.minXorAmount),
                preferredLanguages: .currentLocale
            )
        } else {
            subtitleLabel.sora.text = R.string.soraCard.noFreeKycAttemptsDescription(preferredLanguages: .currentLocale)
        }
    }

    private func setupInitialLayout() {

        addSubview(containerView)

        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        containerView.addArrangedSubviews([
            titleLabel,
            subtitleLabel,
            balanceProgressView,
            button
        ])
    }
}
