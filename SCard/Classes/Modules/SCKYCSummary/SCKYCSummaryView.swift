import UIKit
import SoraUIKit

final class SCKYCSummaryView: UIView {

    var onContinueButton: (() -> Void)?

    private let textLabel: SoramitsuLabel = {
        let label = SoramitsuLabel()
        label.sora.font = FontType.paragraphM
        label.sora.textColor = .fgPrimary
        label.sora.numberOfLines = 0
        label.sora.text = R.string.soraCard.getPreparedNeed(preferredLanguages: .currentLocale)
        return label
    }()

    private let scrollView: UIScrollView = {
        let view = UIScrollView()
        return view
    }()

    private let stackView: SoramitsuStackView = {
        let view = SoramitsuStackView()
        view.sora.axis = .vertical
        view.spacing = 24
        return view
    }()

    private let warningLabel: SoramitsuView = {
        let label = SoramitsuLabel()
        label.sora.font = FontType.paragraphBoldM
        label.sora.textColor = .accentTertiary
        label.sora.numberOfLines = 0
        label.textAlignment = .center
        label.sora.text = R.string.soraCard.getPreparedAlert(preferredLanguages: .currentLocale)
        // TODO: fix SoramitsuLabel contentInsets
        // label.sora.contentInsets = .init(all:  16)
        // label.sora.backgroundColor = .accentTertiaryContainer
        // label.sora.cornerRadius = .small

        let warningContainerView = SoramitsuView()
        warningContainerView.sora.backgroundColor = .accentTertiaryContainer
        warningContainerView.sora.cornerRadius = .medium
        warningContainerView.addSubview(label)
        label.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(16)
        }

        return warningContainerView
    }()

    private lazy var continueButton: SoramitsuButton = {
        let button = SoramitsuButton(size: .large, type: .filled(.secondary))
        button.sora.addHandler(for: .touchUpInside) { [weak self] in
            self?.continueButton.sora.isEnabled = false
            self?.onContinueButton?()
        }
        button.sora.title = R.string.soraCard.getPreparedOkTitle(preferredLanguages: .currentLocale)
        button.sora.cornerRadius = .custom(28)
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        setupInitialLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupInitialLayout() {

        addSubview(scrollView)
        scrollView.addSubview(stackView)
        addSubview(continueButton)

        stackView.addArrangedSubviews(kycSteps())

        scrollView.snp.makeConstraints {
            $0.top.equalTo(self.safeAreaLayoutGuide).offset(16)
            $0.bottom.equalTo(continueButton.snp.top).offset(-24)
            $0.leading.trailing.equalToSuperview()
        }

        stackView.snp.makeConstraints {
            $0.leading.trailing.equalTo(self).inset(24)
            $0.top.bottom.equalToSuperview()
        }

        continueButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.bottom.equalTo(self.safeAreaLayoutGuide).offset(-24)
        }

    }

    private func kycSteps() -> [UIView] {
        [
            warningLabel,
            SCKYSSummaryStepView(
                step: "1",
                title: R.string.soraCard.getPreparedSubmitIdPhotoTitle(preferredLanguages: .currentLocale),
                subtitle: R.string.soraCard.getPreparedSubmitIdPhotoDescription(preferredLanguages: .currentLocale)
            ),
            SCKYSSummaryStepView(
                step: "2",
                title: R.string.soraCard.getPreparedTakeSelfieTitle(preferredLanguages: .currentLocale),
                subtitle: R.string.soraCard.getPreparedTakeSelfieDescription(preferredLanguages: .currentLocale)
            ),
            SCKYSSummaryStepView(
                step: "3",
                title: R.string.soraCard.getPreparedProofAddressTitle(preferredLanguages: .currentLocale),
                subtitle: R.string.soraCard.getPreparedProofAddressDescription(preferredLanguages: .currentLocale)
            ),
            SCKYSSummaryStepView(
                step: "4",
                title: R.string.soraCard.getPreparedPersonalInfoTitle(preferredLanguages: .currentLocale),
                subtitle: R.string.soraCard.getPreparedPersonalInfoDescription(preferredLanguages: .currentLocale)
            )
        ]
    }
}
