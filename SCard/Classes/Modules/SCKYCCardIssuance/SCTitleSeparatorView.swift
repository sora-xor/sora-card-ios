import UIKit
import SoraUIKit

class SCTitleSeparatorView: UIView {

    private let titleLabel: SoramitsuLabel = {
        let view = SoramitsuLabel()
        view.sora.font = FontType.textS
        view.sora.textColor = .fgPrimary
        view.sora.alignment = .center
        view.sora.text = R.string.soraCard.cardOr(preferredLanguages: .currentLocale)
        return view
    }()

    private let leftLineView: SoramitsuView = {
        let view = SoramitsuView()
        view.sora.backgroundColor = .fgTertiary
        return view
    }()

    private let rightLineView: SoramitsuView = {
        let view = SoramitsuView()
        view.sora.backgroundColor = .fgTertiary
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupInitialLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupInitialLayout() {
        addSubview(titleLabel) {
            $0.center.equalToSuperview()
            $0.top.bottom.equalToSuperview()
        }

        addSubview(leftLineView) {
            $0.leading.equalToSuperview().inset(24)
            $0.trailing.equalTo(titleLabel.snp.leading).offset(-16)
            $0.centerY.equalToSuperview()
            $0.height.equalTo(1)
        }

        addSubview(rightLineView) {
            $0.leading.equalTo(titleLabel.snp.trailing).offset(16)
            $0.trailing.equalToSuperview().inset(24)
            $0.centerY.equalToSuperview()
            $0.height.equalTo(1)
        }
    }
}
