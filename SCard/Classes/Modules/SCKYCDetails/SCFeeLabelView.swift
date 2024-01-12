import UIKit
import SoraUIKit

final class SCFeeLabelView: UIView {

    private let iconView: SoramitsuImageView = {
        let view = SoramitsuImageView()
        return view
    }()

    private let titleLabel: SoramitsuLabel = {
        let label = SoramitsuLabel()
        label.sora.font = FontType.displayM
        label.sora.textColor = .fgPrimary
        label.sora.numberOfLines = 0
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = SoramitsuUI.shared.theme.palette.color(.bgSurface)
        setupInitialLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(icon: Picture?, title: String) {
        iconView.sora.picture = icon
        titleLabel.sora.text = title
    }

    private func setupInitialLayout() {

        addSubview(iconView)
        addSubview(titleLabel)

        iconView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.size.equalTo(24)
        }

        titleLabel.snp.makeConstraints {
            $0.leading.equalTo(iconView.snp.trailing).offset(10)
            $0.top.bottom.trailing.equalToSuperview()
        }
    }
}
