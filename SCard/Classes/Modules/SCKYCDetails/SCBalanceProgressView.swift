import UIKit
import SnapKit
import SoraUIKit

final class SCBalanceProgressView: UIView {

    private let progressBGView: SoramitsuView = {
        let view = SoramitsuView()
        view.sora.backgroundColor = .bgSurfaceVariant
        view.sora.cornerRadius = .custom(2)
        return view
    }()

    private let progressView: SoramitsuView = {
        let view = SoramitsuView()
        view.sora.backgroundColor = .accentPrimary
        view.sora.cornerRadius = .custom(2)
        return view
    }()

    private let titleLabel: SoramitsuLabel = {
        let label = SoramitsuLabel()
        label.sora.font = FontType.textBoldS
        label.sora.textColor = .accentPrimary
        label.sora.numberOfLines = 0
        label.sora.alignment = .right
        label.sora.text = "checking balance ..."
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupInitialLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(progressPercentage: Float, needMoreXor: Decimal, needMoreXorInFiat: Decimal) {
        UIView.animate(withDuration: 0.3) {
            self.progressView.snp.remakeConstraints {
                $0.leading.top.bottom.equalToSuperview()
                $0.width.greaterThanOrEqualTo(4)
                $0.width.equalToSuperview().multipliedBy(progressPercentage)
            }
            self.layoutIfNeeded()
        }

        let needMoreXorText = NumberFormatter.polkaswapBalance.stringFromDecimal(needMoreXor) ?? ""
        let needMoreXorInFiatText = NumberFormatter.fiat.stringFromDecimal(needMoreXorInFiat) ?? ""

        if progressPercentage >= SCKYCCardIssuanceViewModel.minAmountOfEuroProcentage {
            titleLabel.sora.text = R.string.soraCard.detailsEnoughXorDesription(preferredLanguages: .currentLocale)
        } else {
            titleLabel.sora.text = R.string.soraCard.detailsNeedXorDesription(
                needMoreXorText,
                needMoreXorInFiatText,
                preferredLanguages: .currentLocale
            )
        }
    }

    private func setupInitialLayout() {

        addSubview(progressBGView) {
            $0.top.equalToSuperview().inset(8)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(4)
        }

        progressBGView.addSubview(progressView) {
            $0.leading.top.bottom.equalToSuperview()
            $0.width.greaterThanOrEqualTo(4)
            $0.width.equalToSuperview().multipliedBy(0.01)
        }

        addSubview(titleLabel) {
            $0.top.equalTo(progressBGView.snp.bottom).offset(4)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
}
