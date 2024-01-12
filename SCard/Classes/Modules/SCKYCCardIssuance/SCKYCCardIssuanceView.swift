import UIKit
import SoraUIKit

final class SCKYCCardIssuanceView: UIView {

    var onLogout: (() -> Void)?
    var onClose: (() -> Void)?
    var onFreeCard: (() -> Void)?
    var onPayForIssueCard: (() -> Void)?
    
    struct Data {
        let percentage: Float
        let needMoreXor: Decimal
        let needMoreXorInFiat: Decimal
        let isKYCFree: Bool
        let issuanceFee: String
    }

    private let scrollView = UIScrollView()

    private var containerView: UIStackView = {
        var view = UIStackView()
        view.backgroundColor = SoramitsuUI.shared.theme.palette.color(.bgPage)
        view.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 24, right: 0)
        view.isLayoutMarginsRelativeArrangement = true
        view.axis = .vertical
        view.spacing = 16
        view.distribution = .fill
        return view
    }()

    private lazy var logoutButton: SoramitsuButton = {
        let button = SoramitsuButton(size: .extraSmall, type: .text(.primary))
        button.sora.title = R.string.soraCard.logOut(preferredLanguages: .currentLocale)
        button.sora.addHandler(for: .touchUpInside) { [weak self] in
            self?.onLogout?()
        }
        return button
    }()

    private lazy var closeButton: ImageButton = {
        let button = ImageButton(size: .init(width: 24, height: 24))
        let image = R.image.close()?.withTintColor(SoramitsuUI.shared.theme.palette.color(.fgPrimary))
        button.setImage(image, for: .normal)
        button.sora.addHandler(for: .touchUpInside) { [unowned self] in
            self.onClose?()
        }
        button.sora.backgroundColor = .custom(uiColor: .clear)
        return button
    }()

    private let titleLabel: SoramitsuLabel = {
        let label = SoramitsuLabel()
        label.sora.font = FontType.headline1
        label.sora.textColor = .fgPrimary
        label.sora.numberOfLines = 0
        label.sora.text = R.string.soraCard.cardIssuanceScreenTitle(preferredLanguages: .currentLocale)
        return label
    }()

    private let getCardView = SCKYCGetFreeCardView()

    private let separatorView = SCTitleSeparatorView()

    private let payFeeView = SCKYCGetCardFeeView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = SoramitsuUI.shared.theme.palette.color(.bgPage)

        setupInitialLayout()

        bindings()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(data: Data) {
        getCardView.configure(
            percentage: data.percentage,
            needMoreXor: data.needMoreXor,
            needMoreXorInFiat: data.needMoreXorInFiat,
            isButtonEnabled: data.isKYCFree
        )
        payFeeView.configure(isButtonEnabled: !data.isKYCFree)
    }

    private func bindings() {
        getCardView.onButton = { [weak self] in
            self?.onFreeCard?()
        }

        payFeeView.onButton = { [weak self] in
            self?.onPayForIssueCard?()
        }
    }

    private func setupInitialLayout() {

        addSubview(scrollView)

        let headerView = UIView()
        headerView.addSubview(logoutButton) {
            $0.top.bottom.leading.equalToSuperview()
            $0.width.greaterThanOrEqualTo(60)
        }

        headerView.addSubview(closeButton) {
            $0.top.bottom.trailing.equalToSuperview()
        }

        containerView.addArrangedSubviews([
            headerView,
            titleLabel,
            getCardView,
            separatorView,
            payFeeView
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
