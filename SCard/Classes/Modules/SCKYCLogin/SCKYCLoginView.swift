import UIKit
import SoraUIKit

final class SCKYCLoginView: UIView {

    var onLogin: (() -> Void)?
    var onUnsupportedCountries: (() -> Void)?

    private let scrollView = UIScrollView()

    private var containerView: SoramitsuStackView = {
        var view = SoramitsuStackView()
        view.sora.backgroundColor = .bgSurface
        view.sora.axis = .vertical
        view.sora.shadow = .default
        view.spacing = 16
        view.sora.cornerRadius = .max
        view.sora.distribution = .fill
        view.layoutMargins = UIEdgeInsets(top: 24, left: 24, bottom: 24, right: 24)
        view.isLayoutMarginsRelativeArrangement = true
        return view
    }()

    private let iconView: SoramitsuImageView = {
        let view = SoramitsuImageView()
        let icon = R.image.scFront()
//        UIImage(named: "scFront", in: Bundle(for: SCKYCDetailsView.self), compatibleWith: nil)
        view.sora.picture = .logo(image: R.image.scFront()!)
        return view
    }()

    private let titleLabel: SoramitsuLabel = {
        let label = SoramitsuLabel()
        label.sora.font = FontType.headline1
        label.sora.textColor = .fgPrimary
        label.sora.numberOfLines = 0
        label.sora.text = R.string.soraCard.detailsTitle(preferredLanguages: .currentLocale)
        return label
    }()

    private let textLabel: SoramitsuLabel = {
        let label = SoramitsuLabel()
        label.sora.font = FontType.paragraphM
        label.sora.textColor = .fgPrimary
        label.sora.numberOfLines = 0
        label.sora.text = R.string.soraCard.detailsDescription(preferredLanguages: .currentLocale)
        return label
    }()

    private var feeContainerView: SoramitsuStackView = {
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

    private let feeLabel: SoramitsuLabel = {
        let label = SoramitsuLabel()
        label.sora.text = R.string.soraCard.detailsAnnualServiceFee(preferredLanguages: .currentLocale)
        label.sora.font = FontType.displayM
        label.sora.textColor = .fgPrimary
        label.sora.numberOfLines = 0
        return label
    }()

    private var detailsContainerView: SoramitsuStackView = {
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

    private let detailsTitleLabel: SoramitsuLabel = {
        let label = SoramitsuLabel()
        label.sora.text = R.string.soraCard.detailsFreeCardIssuance(preferredLanguages: .currentLocale)
        label.sora.font = FontType.displayM
        label.sora.textColor = .fgPrimary
        label.sora.numberOfLines = 0
        return label
    }()

    private let detailsDescriptionLabel: SoramitsuLabel = {
        let label = SoramitsuLabel()
        label.sora.font = FontType.paragraphM
        label.sora.textColor = .fgPrimary
        label.sora.numberOfLines = 0
        label.sora.text = R.string.soraCard.detailsFreeCardIssuanceConditionsXor(preferredLanguages: .currentLocale)
        return label
    }()

    private let detailsFeeLabel: SoramitsuLabel = {
        let label = SoramitsuLabel()
        label.sora.font = FontType.paragraphM
        label.sora.textColor = .fgSecondary
        label.sora.text = R.string.soraCard.detailsFreeCardIssuanceConditionsEuro(preferredLanguages: .currentLocale)
        return label
    }()

    private let unsupportedCountriesDisclaimerLabel: SoramitsuLabel = {
        let label = SoramitsuLabel()
        label.sora.font = FontType.paragraphXS
        label.sora.textColor = .fgPrimary
        label.sora.numberOfLines = 0
        label.sora.alignment = .center
        label.sora.text = R.string.soraCard.unsupportedCountriesDisclaimer(preferredLanguages: .currentLocale)
        return label
    }()

    private lazy var unsupportedCountriesButton: SoramitsuButton = {
        let button = SoramitsuButton(size: .large, type: .text(.primary))
        button.sora.addHandler(for: .touchUpInside) { [weak self] in
            self?.onUnsupportedCountries?()
        }
        button.sora.title = R.string.soraCard.unsupportedCountriesLink(preferredLanguages: .currentLocale)

        let text = R.string.soraCard.unsupportedCountriesLink(preferredLanguages: .currentLocale)
        button.sora.attributedText = SoramitsuTextItem(text: text, fontData: FontType.paragraphXS, textColor: .accentPrimary, alignment: .center, underline: .single)

        button.snp.makeConstraints {
            $0.height.equalTo(30)
        }

        return button
    }()

    private lazy var actionButton: SoramitsuButton = {
        let button = SoramitsuButton(size: .large, type: .filled(.primary))
        button.sora.addHandler(for: .touchUpInside) { [weak self] in
            self?.actionButton.sora.isEnabled = false
            self?.onLogin?()
            self?.actionButton.sora.isEnabled = true
        }
        button.sora.title = R.string.soraCard.loginTitle(preferredLanguages: .currentLocale)
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

        detailsContainerView.addArrangedSubviews([
            detailsTitleLabel,
            detailsDescriptionLabel,
            detailsFeeLabel
        ])

        feeContainerView.addArrangedSubview(feeLabel)

        containerView.addArrangedSubviews([
            iconView,
            titleLabel,
            textLabel,
            feeContainerView,
            detailsContainerView,
            unsupportedCountriesDisclaimerLabel,
            unsupportedCountriesButton,
            actionButton
        ])

        scrollView.addSubview(containerView)

        scrollView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        containerView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.leading.trailing.equalTo(self).inset(16)
        }
    }
}
