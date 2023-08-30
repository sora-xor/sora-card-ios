import UIKit
import SoraUIKit

final class SCCardHubView: UIView {

    var onLogout: (() -> Void)?
    var onIban: ((String) -> Void)?

    private let scrollView = UIScrollView()

    // TODO: use table if needed
    private var containerView: SoramitsuStackView = {
        var view = SoramitsuStackView()
        view.sora.axis = .vertical
        view.sora.backgroundColor = .custom(uiColor: .clear)
        view.spacing = 16
        return view
    }()

    private var cardContainerView: SoramitsuStackView = {
        var view = SoramitsuStackView()
        view.sora.backgroundColor = .bgSurface
        view.sora.axis = .vertical
        view.sora.shadow = .default
        view.spacing = 16
        view.sora.cornerRadius = .max
        view.sora.distribution = .fill
        view.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        view.isLayoutMarginsRelativeArrangement = true
        return view
    }()

    private let iconView: SoramitsuImageView = {
        let view = SoramitsuImageView()
        view.sora.picture = .logo(image: R.image.scFront()!)
        view.snp.makeConstraints {
            $0.width.equalTo(view.snp.height).multipliedBy(1.66)
        }
        return view
    }()

    private let titleLabel: SoramitsuLabel = {
        let label = SoramitsuLabel()
        label.sora.font = FontType.textS
        label.sora.textColor = .fgSecondary
        label.sora.alignment = .center
        label.sora.text = R.string.soraCard.cardhubComingSoon(preferredLanguages: .currentLocale)
        return label
    }()

    private let actionButtonsView: SoramitsuStackView = {
        var view = SoramitsuStackView()
        view.sora.backgroundColor = .custom(uiColor: .clear)
        view.sora.axis = .horizontal
        view.sora.distribution = .equalSpacing
        view.sora.alignment = .center
        view.sora.shadow = .small
        view.spacing = 20
        view.clipsToBounds = false
        return view
    }()

    private let topUpButton: SCActionButtonView = {
        let view = SCActionButtonView()
        view.titleLabel.sora.text = R.string.soraCard.cardhubTopUp(preferredLanguages: .currentLocale)
        view.button.sora.leftImage = R.image.newArrowDown()
        view.button.sora.horizontalOffset = 16
        view.button.sora.addHandler(for: .touchUpInside) {
            // TODO:
            print("### Top up")
        }
        view.button.isEnabled = false
        return view
    }()

    private let transferButton: SCActionButtonView = {
        let view = SCActionButtonView()
        view.titleLabel.sora.text = R.string.soraCard.cardhubTransfer(preferredLanguages: .currentLocale)
        view.button.sora.leftImage = R.image.newArrowUp()
        view.button.sora.horizontalOffset = 16
        view.button.sora.addHandler(for: .touchUpInside) {
            // TODO:
            print("### Transfer")
        }
        view.button.isEnabled = false
        return view
    }()

    private let exchangeButton: SCActionButtonView = {
        let view = SCActionButtonView()
        view.titleLabel.sora.text = R.string.soraCard.cardhubExchange(preferredLanguages: .currentLocale)
        view.button.sora.leftImage = R.image.exchange()
        view.button.sora.horizontalOffset = 16
        view.button.sora.addHandler(for: .touchUpInside) {
            // TODO:
            print("### Exchange")
        }
        view.button.isEnabled = false
        return view
    }()

    private let freezeButton: SCActionButtonView = {
        let view = SCActionButtonView()
        view.titleLabel.sora.text = R.string.soraCard.cardhubFreeze(preferredLanguages: .currentLocale)
        view.button.sora.leftImage = R.image.freeze()
        view.button.sora.horizontalOffset = 16
        view.button.sora.addHandler(for: .touchUpInside) {
            // TODO:
            print("### Freeze")
        }
        view.button.isEnabled = false
        return view
    }()

    private var ibanContainerView: SoramitsuStackView = {
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

    private let ibanTitleLabel: SoramitsuLabel = {
        let label = SoramitsuLabel()
        label.sora.font = FontType.headline2
        label.sora.textColor = .fgPrimary
        label.sora.numberOfLines = 0
        label.sora.text = R.string.soraCard.cardhubIbanTitle(preferredLanguages: .currentLocale)
        return label
    }()

    private lazy var ibanCopyButton: SoramitsuButton = {
        let button = SoramitsuButton(size: .large, type: .bleached(.tertiary))
        button.sora.tintColor = .accentTertiary
        button.sora.backgroundColor = .custom(uiColor: .clear)
        button.sora.leftImage = R.image.upload()
        button.sora.addHandler(for: .touchUpInside) { [weak self] in
            self?.onIban?(self?.ibanLabel.sora.text ?? "")
        }
        return button
    }()

    private let ibanLabel: SoramitsuLabel = {
        let label = SoramitsuLabel()
        label.sora.font = FontType.textM
        label.sora.textColor = .fgPrimary
        label.sora.numberOfLines = 0
        label.sora.text = ""
        return label
    }()

    private var settingsContainerView: SoramitsuStackView = {
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

    private let settingsTitleLabel: SoramitsuLabel = {
        let label = SoramitsuLabel()
        label.sora.font = FontType.headline2
        label.sora.textColor = .fgPrimary
        label.sora.numberOfLines = 0
        label.sora.text = R.string.soraCard.cardHubSettingsTitle(preferredLanguages: .currentLocale)
        return label
    }()

    private lazy var logoutView: SCTitleIconView = {
        let view = SCTitleIconView()
        view.rightImageView.image = R.image.arrowRightSmall()
        view.titleLabel.sora.text = R.string.soraCard.cardHubSettingsLogoutTitle(preferredLanguages: .currentLocale)
        view.titleLabel.sora.textColor = .statusError
        view.addTapGesture { [weak self] _ in
            self?.onLogout?()
        }
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupInitialLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(iban: String?) {
        ibanLabel.sora.text = iban
    }

    private func setupInitialLayout() {

        addSubview(scrollView)

        actionButtonsView.addArrangedSubviews([
            topUpButton,
            transferButton,
            exchangeButton,
            freezeButton
        ])

        cardContainerView.addArrangedSubviews([
            iconView,
            titleLabel,
            actionButtonsView
        ])

        let ibanLabelView = SoramitsuView()
        ibanLabelView.addTapGesture { [weak self] _ in
            UIPasteboard.general.string = self?.ibanLabel.sora.text
            self?.showToast(
                message: R.string.soraCard.commonCopied(preferredLanguages: .currentLocale),
                font: FontType.textM.font
            )
        }
        ibanLabelView.addSubview(ibanLabel) {
            $0.edges.equalToSuperview()
        }

        let stackView = UIStackView(arrangedSubviews: [ibanTitleLabel, ibanCopyButton])
        ibanContainerView.addArrangedSubviews([
            stackView,
            ibanLabelView
        ])

        ibanCopyButton.snp.makeConstraints {
            $0.width.equalTo(24)
        }

        settingsContainerView.addArrangedSubviews([
            settingsTitleLabel,
            logoutView
        ])

        containerView.addArrangedSubviews([
            cardContainerView,
            ibanContainerView,
            settingsContainerView
        ])

        scrollView.addSubview(containerView)

        scrollView.snp.makeConstraints {
            $0.top.equalTo(self.safeAreaLayoutGuide).offset(24)
            $0.leading.trailing.bottom.equalToSuperview()
        }

        containerView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.leading.trailing.equalTo(self).inset(16)
        }
    }

    @objc private func onCopy() {
        UIPasteboard.general.string = ibanLabel.sora.text
        showToast(message: "Copied", font: FontType.textM.font)
    }

    private func showToast(message : String, font: UIFont) {
        let toastLabel = UILabel()
        toastLabel.textColor = UIColor.white
        toastLabel.font = font
        toastLabel.textAlignment = .center;
        toastLabel.text = message

        let toastView = UIView()
        toastView.backgroundColor = .black.withAlphaComponent(0.8)
        toastView.layer.cornerRadius = 10;
        toastView.clipsToBounds  =  true
        toastView.addSubview(toastLabel) {
            $0.top.bottom.equalToSuperview().inset(5)
            $0.leading.trailing.equalToSuperview().inset(8)
        }

        self.addSubview(toastView) {
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().multipliedBy(0.8)
        }

        UIView.animate(withDuration: 1.0, delay: 0.5, options: .curveEaseOut,
        animations: {
            toastView.alpha = 0.0
        }, completion: { _ in
            toastView.removeFromSuperview()
        })
    }
}
