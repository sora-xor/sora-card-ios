import Foundation
import AVFoundation
import PayWingsOAuthSDK
import PayWingsOnboardingKYC

final class SCKYCOnbordingViewModel {
    var onContinue: ((SCKYCUserDataModel) -> Void)?
    weak var viewController: UIViewController?
    
    private var result = VerificationResult()
    private var kycSuccess: PayWingsOnboardingKYC.SuccessEvent?

    init(data: SCKYCUserDataModel, service: SCKYCService, storage: SCStorage) {
        self.data = data
        self.service = service
        self.storage = storage
        self.result.delegate = self
    }

    func referenceNumber() async -> String? {
        let result = await service.referenceNumber(
            phone: data.phoneNumber,
            email: data.email
        )

        switch result {
        case .success(let respons):
            data.referenceNumber = respons.referenceNumber
            data.referenceId = respons.referenceID
            return data.referenceNumber
        case .failure(let error):
            print(error)
            showErrorAlert(title: "Error", message: error.errorDescription ?? error.localizedDescription)
            return nil
        }
    }

    func set(kycId: String) {
        data.kycId = kycId
        storage.add(kycId: kycId)
    }

    private let data: SCKYCUserDataModel
    private let service: SCKYCService
    private let storage: SCStorage

    func startKYC() {
        checkCameraPermission()
    }

    private func goToKyc() {

        Task {
            let referenceNumber = await referenceNumber()
            let referenceId = data.referenceId
            let token = await SCStorage.shared.token()

            let language = UserDefaults.standard.string(forKey: "language_preference") ?? ""
            let settings = KycSettings(referenceID: referenceId, referenceNumber: referenceNumber, language: language)

            let credentials = KycCredentials(
                username: service.config.kycUsername,
                password: service.config.kycPassword,
                endpointUrl: service.config.kycUrl
            )

            let userData = KycUserData(
                firstName: data.name,
                middleName: "",
                lastName: data.lastname,
                address1: "",
                address2: "",
                address3: "",
                zipCode: "",
                city: "",
                state: "",
                countryCode: "",
                email: data.email,
                mobileNumber: data.phoneNumber
            )

            DispatchQueue.main.async {

                let cameraAuthorized = (AVCaptureDevice.authorizationStatus(for: AVMediaType.video) == .authorized) ? true : false
                let microphoneAuthorized = (AVCaptureDevice.authorizationStatus(for: AVMediaType.audio) == .authorized) ? true : false

                let accessToken = token?.accessToken ?? ""
                let refreshToken = token?.refreshToken
                let userCredentials = UserCredentials(accessToken: accessToken, refreshToken: refreshToken)
                if cameraAuthorized && microphoneAuthorized {
                    let config = KycConfig(
                        credentials: credentials,
                        settings: settings,
                        userData: userData,
                        userCredentials:userCredentials
                    )
                    PayWingsOnboardingKyc.startKyc(vc: self.viewController ?? .init(), config: config, result: self.result)
                }
            }
        }
    }

    private func checkCameraPermission() {

        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            checkMicrophonePermission()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted: Bool) -> Void in
                if granted == true {
                    self.checkMicrophonePermission()
                }
            })
        case .denied:
            showPhoneSettings(type: PermissionType.Camera.rawValue)
        case .restricted:
            return
        default:
            fatalError(NSLocalizedString("Camera Authorization Status not handled!", comment: ""))
        }
    }

    private func checkMicrophonePermission() {

        switch AVAudioSession.sharedInstance().recordPermission {
        case .granted:
            goToKyc()
        case .denied:
            showPhoneSettings(type: PermissionType.Microphone.rawValue)
        case .undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission({ (granted) in
                if granted {
                    self.goToKyc()
                }
            })
        default:
            fatalError(NSLocalizedString("Microphone Authorization Status not handled!", comment: ""))
        }
    }

    private func showPhoneSettings(type: String) {
        let alertController = UIAlertController(
            title: "Permission Error",
            message: "Permission for \(type) access denied, please allow our app permission through Settings in your phone if you want to use our service.",
            preferredStyle: .alert
        )
        alertController.addAction(UIAlertAction(title: "Cancel", style: .default))
        alertController.addAction(UIAlertAction(title: "Settings", style: .cancel) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: { _ in })
            }
        })
        viewController?.present(alertController, animated: true)
    }

    private func showErrorAlert(title: String, message: String) {
        let alertController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        alertController.addAction(UIAlertAction(title: "Cancel", style: .default))
        viewController?.present(alertController, animated: true)
    }
}

extension SCKYCOnbordingViewModel: VerificationResultDelegate {
    func success(result: PayWingsOnboardingKYC.SuccessEvent) {
        kycSuccess = result
        set(kycId: result.KycID ?? "")
        onContinue?(data)
    }

    func error(result: PayWingsOnboardingKYC.ErrorEvent) {
        onContinue?(data)
    }
}

private enum PermissionType : String {
    case Camera
    case Microphone
}
