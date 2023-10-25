import UIKit
import SoraUIKit

class SCCountryCell: UITableViewCell {

    private static let iconSize: CGFloat = 24

    let icon: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .gray
        imageView.contentMode = .center
        imageView.layer.cornerRadius = SCCountryCell.iconSize / 2
        imageView.clipsToBounds = true
        return imageView
    }()

    let title: SoramitsuLabel = {
        let label = SoramitsuLabel()
        label.sora.font = FontType.textM
        label.sora.textColor = .fgPrimary
        label.sora.alignment = .left
        label.sora.numberOfLines = 2
        return label
    }()

    let subtitle: SoramitsuLabel = {
        let label = SoramitsuLabel()
        label.sora.font = FontType.textBoldXS
        label.sora.textColor = .fgSecondary
        label.sora.alignment = .left
        label.sora.numberOfLines = 2
        return label
    }()

    let value: SoramitsuLabel = {
        let label = SoramitsuLabel()
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        label.sora.font = FontType.textM
        label.sora.textColor = .fgPrimary
        label.sora.alignment = .right
        return label
    }()


    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupInitialLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupInitialLayout() {

        contentView.addSubview(icon) {
            $0.leading.equalToSuperview().inset(24)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(Self.iconSize)
        }

        contentView.addSubview(title) {
            $0.leading.equalTo(icon.snp.trailing).offset(8)
            $0.top.equalToSuperview().inset(16)
        }

        contentView.addSubview(subtitle) {
            $0.leading.equalTo(icon.snp.trailing).offset(8)
            $0.top.equalTo(title.snp.bottom).offset(4)
            $0.bottom.equalToSuperview().inset(16)
        }

        contentView.addSubview(value) {
            $0.trailing.equalToSuperview().inset(24)
            $0.centerY.equalToSuperview()
            $0.leading.greaterThanOrEqualTo(title.snp.trailing).offset(8)
            $0.leading.greaterThanOrEqualTo(subtitle.snp.trailing).offset(8)
        }
    }
}
