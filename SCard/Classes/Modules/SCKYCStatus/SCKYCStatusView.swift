import UIKit
import SoraUIKit

final class SCKYCStatusView: UIView {

    var onRetryButton: (() -> Void)?
    var onResetButton: (() -> Void)?
    var onCloseButton: (() -> Void)?
    var onSupportButton: (() -> Void)?

    private lazy var supportButton: SoramitsuButton = {
        let button = SoramitsuButton(size: .extraSmall, type: .text(.primary))
        button.sora.addHandler(for: .touchUpInside) { [weak self] in
            self?.onSupportButton?()
        }
        button.sora.title = R.string.soraCard.verificationRejectedSupport(preferredLanguages: .currentLocale)
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

    private lazy var closeButton: SoramitsuButton = {
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
        supportButton.sora.isHidden = false
        closeButton.sora.title = R.string.soraCard.commonTryAgain(preferredLanguages: .currentLocale)
        closeButton.sora.removeAllHandlers(for: .touchUpInside)
        closeButton.sora.addHandler(for: .touchUpInside) { [weak self] in
            self?.onResetButton?()
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

        case .successful:
            titleLabel.sora.text = R.string.soraCard.verificationSuccessfulTitle(preferredLanguages: .currentLocale)
            textLabel.sora.text = R.string.soraCard.verificationSuccessfulDescription(preferredLanguages: .currentLocale)
            iconView.sora.picture = .logo(image: R.image.kycSuccessful()!)

        case .notStarted:
            titleLabel.sora.text = R.string.soraCard.verificationFailedTitle(preferredLanguages: .currentLocale)
            textLabel.sora.text = R.string.soraCard.verificationFailedDescription(preferredLanguages: .currentLocale)
            iconView.sora.picture = .logo(image: R.image.kycRejected()!)

            closeButton.sora.type = .filled(.secondary)
            closeButton.sora.title = R.string.soraCard.commonTryAgain(preferredLanguages: .currentLocale)
            closeButton.sora.removeAllHandlers(for: .touchUpInside)
            closeButton.sora.addHandler(for: .touchUpInside) { [weak self] in
                self?.onRetryButton?()
            }

        case .rejected:
            if hasFreeAttemts {
                titleLabel.sora.text = R.string.soraCard.verificationRejectedTitle(preferredLanguages: .currentLocale)
                textLabel.sora.text = R.string.soraCard.verificationRejectedDescription(preferredLanguages: .currentLocale)
                iconView.sora.picture = .logo(image: R.image.kycRejected()!)

                closeButton.sora.type = .filled(.secondary)
                closeButton.sora.title = R.string.soraCard.commonTryAgain(preferredLanguages: .currentLocale)
                closeButton.sora.removeAllHandlers(for: .touchUpInside)
                closeButton.sora.addHandler(for: .touchUpInside) { [weak self] in
                    self?.onRetryButton?()
                }
            } else {
                titleLabel.sora.text = R.string.soraCard.noFreeKycAttemptsTitle(preferredLanguages: .currentLocale)
                textLabel.sora.text = R.string.soraCard.noFreeKycAttemptsDescription(preferredLanguages: .currentLocale)
                iconView.sora.picture = .logo(image: R.image.kycPending()!)
                supportButton.sora.isHidden = false
            }
        }
    }

    private func setupInitialLayout() {

        addSubview(supportButton)
        addSubview(titleLabel)
        addSubview(textLabel)
        addSubview(closeButton)

        supportButton.snp.makeConstraints {
            $0.top.equalTo(self.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview().inset(24)
        }

        titleLabel.snp.makeConstraints {
            $0.top.equalTo(supportButton.snp.bottom).offset(10)
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
            $0.bottom.equalTo(closeButton.snp.top)
        }

        containerView.addSubview(iconView)

        iconView.snp.makeConstraints {
            $0.top.bottom.lessThanOrEqualToSuperview().inset(8)
            $0.width.lessThanOrEqualToSuperview().multipliedBy(0.75)
            $0.center.equalToSuperview()
        }

        closeButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.bottom.equalTo(self.safeAreaLayoutGuide).offset(-24)
        }

        addSubview(activityIndicatorView) {
            $0.center.equalToSuperview()
        }
    }
}
