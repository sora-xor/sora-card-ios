import UIKit
import SoraUIKit

class SCKYCGetCardFeeView: UIView {

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
        label.sora.text = R.string.soraCard.cardIssuanceScreenPaidCardTitle(
            SCard.issuanceFee,
            preferredLanguages: .currentLocale
        )
        return label
    }()

    private let subtitleLabel: SoramitsuLabel = {
        let label = SoramitsuLabel()
        label.sora.font = FontType.paragraphM
        label.sora.textColor = .fgPrimary
        label.sora.numberOfLines = 0
        label.sora.text = R.string.soraCard.cardIssuanceScreenPaidCardDescription(preferredLanguages: .currentLocale)
        return label
    }()

    private let noteLabel: SoramitsuLabel = {
        let label = SoramitsuLabel()
        label.sora.font = FontType.paragraphM
        label.sora.textColor = .statusWarning
        label.sora.numberOfLines = 0
        label.sora.text = R.string.soraCard.cardIssuanceScreenPaidCardNote(preferredLanguages: .currentLocale)
        return label
    }()

    private lazy var button: SoramitsuButton = {
        let button = SoramitsuButton(size: .large, type: .filled(.secondary))
        button.sora.addHandler(for: .touchUpInside) { [weak self] in
            self?.button.sora.isEnabled = false
            self?.onButton?()
            self?.button.sora.isEnabled = true
        }
        button.sora.title = R.string.soraCard.cardIssuanceScreenPaidCardPayEuro(
            SCard.issuanceFee,
            preferredLanguages: .currentLocale
        )
        button.sora.cornerRadius = .custom(28)
        button.sora.isEnabled = false
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupInitialLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(isButtonEnabled: Bool) {
        button.sora.isEnabled = isButtonEnabled
    }

    private func setupInitialLayout() {

        addSubview(containerView)

        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        containerView.addArrangedSubviews([
            titleLabel,
            subtitleLabel,
            noteLabel,
            button
        ])
    }
}
