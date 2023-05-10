import UIKit
import SoraUIKit

final class SCKYCStatusView: UIView {

    var onLogoutButton: (() -> Void)?
    var onRetryButton: (() -> Void)?
    var onSupportButton: (() -> Void)?
    var onCloseButton: (() -> Void)?

    private lazy var logoutButton: SoramitsuButton = {
        let button = SoramitsuButton(size: .extraSmall, type: .text(.primary))
        button.sora.addHandler(for: .touchUpInside) { [weak self] in
            self?.onLogoutButton?()
        }
        button.sora.title = "Log out" // TODO:
        button.sora.isHidden = true
        return button
    }()

    private let titleLabel: SoramitsuLabel = {
        let label = SoramitsuLabel()
        label.sora.font = FontType.headline1
        label.sora.textColor = .fgPrimary
        return label
    }()

    private let textLabel: SoramitsuLabel = {
        let label = SoramitsuLabel()
        label.sora.font = FontType.paragraphM
        label.sora.textColor = .fgPrimary
        label.sora.numberOfLines = 0
        return label
    }()

    private let iconView: SoramitsuImageView = {
        let view = SoramitsuImageView()
        view.sora.contentMode = .scaleAspectFit
        return view
    }()


    private let actionDescriptionLabel: SoramitsuLabel = {
        let label = SoramitsuLabel()
        label.sora.font = FontType.paragraphM
        label.sora.textColor = .fgPrimary
        label.sora.numberOfLines = 0
        label.sora.alignment = .center
        return label
    }()

    private lazy var actionButton: SoramitsuButton = {
        let button = SoramitsuButton(size: .large, type: .filled(.secondary))
        button.sora.addHandler(for: .touchUpInside) { [weak self] in
            self?.onRetryButton?()
        }
        button.sora.cornerRadius = .custom(28)
        button.sora.title = "Try again for free" // TODO:
        button.sora.isHidden = true
        return button
    }()

    private lazy var secondButton: SoramitsuButton = {
        let button = SoramitsuButton(size: .large, type: .tonal(.secondary))
        button.sora.addHandler(for: .touchUpInside) { [weak self] in
            self?.onCloseButton?()
        }
        button.sora.cornerRadius = .custom(28)
        button.sora.title = R.string.soraCard.commonClose(preferredLanguages: .currentLocale)
        return button
    }()

    private let activityIndicatorView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .medium)
        view.hidesWhenStopped = true
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        setupInitialLayout()
        activityIndicatorView.startAnimating()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(error: String) {
        activityIndicatorView.stopAnimating()
        titleLabel.sora.text = R.string.soraCard.commonErrorGeneralTitle(preferredLanguages: .currentLocale)
        textLabel.sora.text = "\(error)"
        actionButton.sora.title = R.string.soraCard.commonTryAgain(preferredLanguages: .currentLocale)
        actionButton.sora.removeAllHandlers(for: .touchUpInside)
        actionButton.sora.addHandler(for: .touchUpInside) { [weak self] in
            self?.onRetryButton?()
        }
        iconView.sora.picture = .logo(image: R.image.kycRejected()!)
    }

    func configure(state: SCKYCUserStatus, hasFreeAttemts: Bool) {
        activityIndicatorView.stopAnimating()
        switch state {
        case .pending:
            titleLabel.sora.text = R.string.soraCard.kycResultVerificationInProgress()
            textLabel.sora.text = R.string.soraCard.kycResultVerificationInProgressDescription(preferredLanguages: .currentLocale)
            iconView.sora.picture = .logo(image: R.image.kycPending()!)
            actionButton.sora.isHidden = true

            secondButton.sora.title = R.string.soraCard.verificationRejectedSupport(preferredLanguages: .currentLocale)
            secondButton.sora.removeAllHandlers(for: .touchUpInside)
            secondButton.sora.addHandler(for: .touchUpInside) { [weak self] in
                self?.onSupportButton?()
            }

        case .successful:
            titleLabel.sora.text = R.string.soraCard.verificationSuccessfulTitle(preferredLanguages: .currentLocale)
            textLabel.sora.text = R.string.soraCard.verificationSuccessfulDescription(preferredLanguages: .currentLocale)
            iconView.sora.picture = .logo(image: R.image.kycSuccessful()!)
            actionButton.sora.isHidden = true

            secondButton.sora.title = "Close"
            secondButton.sora.removeAllHandlers(for: .touchUpInside)
            secondButton.sora.addHandler(for: .touchUpInside) { [weak self] in
                self?.onCloseButton?()
            }

        case .notStarted, .userCanceled:
            titleLabel.sora.text = R.string.soraCard.verificationFailedTitle(preferredLanguages: .currentLocale)
            textLabel.sora.text = R.string.soraCard.verificationFailedDescription(preferredLanguages: .currentLocale)
            iconView.sora.picture = .logo(image: R.image.kycRejected()!)

            actionButton.sora.isHidden = false
            actionButton.sora.type = .filled(.secondary)
            actionButton.sora.title = R.string.soraCard.commonTryAgain(preferredLanguages: .currentLocale)

            secondButton.sora.title = R.string.soraCard.verificationRejectedSupport(preferredLanguages: .currentLocale)
            secondButton.sora.removeAllHandlers(for: .touchUpInside)
            secondButton.sora.addHandler(for: .touchUpInside) { [weak self] in
                self?.onSupportButton?()
            }

        case .rejected:

            titleLabel.sora.text = R.string.soraCard.verificationRejectedTitle(preferredLanguages: .currentLocale)
            textLabel.sora.text = "Your application has been rejected."
            iconView.sora.picture = .logo(image: R.image.kycRejected()!)

            actionButton.sora.isHidden = false

            if hasFreeAttemts {
                actionDescriptionLabel.sora.text = "You have 1 more free KYC attempt.\nEvery other attempt will cost you €3.80"
                actionButton.sora.title = "Try again for free"
            } else {
                actionDescriptionLabel.sora.text = "You have used your free KYC attempts.\nEvery other attempt will cost you €3.80"
                actionButton.sora.title = "Try again for €3.80"
            }

            secondButton.sora.title = R.string.soraCard.verificationRejectedSupport(preferredLanguages: .currentLocale)
            secondButton.sora.removeAllHandlers(for: .touchUpInside)
            secondButton.sora.addHandler(for: .touchUpInside) { [weak self] in
                self?.onSupportButton?()
            }
        }
    }

    private func setupInitialLayout() {

        addSubview(logoutButton)
        addSubview(titleLabel)
        addSubview(textLabel)
        addSubview(actionButton)

        logoutButton.snp.makeConstraints {
            $0.top.equalTo(self.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview().inset(24)
        }

        titleLabel.snp.makeConstraints {
            $0.top.equalTo(logoutButton.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview().inset(24)
        }

        textLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(24)
        }

        let containerView = UIView()
        addSubview(containerView)

        containerView.snp.makeConstraints {
            $0.top.equalTo(textLabel.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(actionButton.snp.top)
        }

        containerView.addSubview(iconView)

        iconView.snp.makeConstraints {
            $0.top.bottom.lessThanOrEqualToSuperview().inset(8)
            $0.width.lessThanOrEqualToSuperview().multipliedBy(0.75)
            $0.center.equalToSuperview()
        }

        let buttonsView = UIStackView(arrangedSubviews: [
            actionDescriptionLabel,
            actionButton,
            secondButton
        ])
        buttonsView.axis = .vertical
        buttonsView.spacing = 16

        addSubview(buttonsView) {
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.bottom.equalTo(self.safeAreaLayoutGuide).offset(-24)
        }

        addSubview(activityIndicatorView) {
            $0.center.equalToSuperview()
        }
    }
}
