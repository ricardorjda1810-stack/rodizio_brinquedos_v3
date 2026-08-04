import FirebaseAppCheck
import FirebaseCore
import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    #if APP_ATTEST_RELEASE_STAGING
      AppCheck.setAppCheckProviderFactory(AppAttestProviderFactory())
      FirebaseApp.configure()
    #endif
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    if let registrar = engineBridge.pluginRegistry.registrar(
      forPlugin: "StoreKitReconciliationPlugin"
    ) {
      StoreKitReconciliationPlugin.register(with: registrar)
    }
  }
}
