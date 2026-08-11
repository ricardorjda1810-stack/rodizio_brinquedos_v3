import Flutter
import StoreKit

final class StoreKitReconciliationPlugin: NSObject, FlutterPlugin {
  private static let channelName =
    "com.rodiziobrinquedos.v3/storekit_reconciliation"
  private static let supportedProductIds: Set<String> = [
    "com.rodiziobrinquedos.premium.monthly",
    "com.rodiziobrinquedos.premium.yearly",
  ]

  static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: channelName,
      binaryMessenger: registrar.messenger()
    )
    registrar.addMethodCallDelegate(
      StoreKitReconciliationPlugin(),
      channel: channel
    )
  }

  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "snapshot":
      loadSnapshot(result: result)
    case "finish":
      finishTransaction(arguments: call.arguments, result: result)
    case "pricingDiagnostics":
      loadPricingDiagnostics(result: result)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func loadPricingDiagnostics(result: @escaping FlutterResult) {
    guard #available(iOS 15.0, *) else {
      result(["status": "unavailable"])
      return
    }

    Task { @MainActor in
      do {
        let requestedProductIds = Self.supportedProductIds.sorted()
        let storefront = await Storefront.current
        let loadedProducts = try await Product.products(
          for: requestedProductIds
        )
        let products = loadedProducts.sorted { $0.id < $1.id }
        let foundProductIds = Set(products.map(\.id))
        let missingProductIds = requestedProductIds.filter {
          !foundProductIds.contains($0)
        }

        let storefrontRepresentation: [String: Any]
        if let storefront {
          storefrontRepresentation = [
            "status": "available",
            "countryCode": storefront.countryCode,
            "id": storefront.id,
          ]
        } else {
          storefrontRepresentation = ["status": "unavailable"]
        }

        result([
          "status": "success",
          "storefront": storefrontRepresentation,
          "products": products.map { product in
            [
              "productId": product.id,
              "displayPrice": product.displayPrice,
              "rawPrice": NSDecimalNumber(decimal: product.price).stringValue,
              "currencyCode": product.priceFormatStyle.currencyCode,
            ]
          },
          "notFoundProductIds": missingProductIds,
        ])
      } catch {
        result(
          FlutterError(
            code: "storekit_pricing_failed",
            message: nil,
            details: nil
          )
        )
      }
    }
  }

  private func loadSnapshot(result: @escaping FlutterResult) {
    guard #available(iOS 15.0, *) else {
      result(["status": "unavailable"])
      return
    }

    Task { @MainActor in
      var unfinished: [[String: Any]] = []
      var currentEntitlements: [[String: Any]] = []

      for await verificationResult in Transaction.unfinished {
        guard case .verified(let transaction) = verificationResult else {
          continue
        }
        unfinished.append(Self.technicalRepresentation(of: transaction))
      }

      for await verificationResult in Transaction.currentEntitlements {
        guard case .verified(let transaction) = verificationResult else {
          continue
        }
        currentEntitlements.append(
          Self.technicalRepresentation(of: transaction)
        )
      }

      result([
        "status": "success",
        "unfinished": unfinished,
        "currentEntitlements": currentEntitlements,
      ])
    }
  }

  private func finishTransaction(
    arguments: Any?,
    result: @escaping FlutterResult
  ) {
    guard #available(iOS 15.0, *) else {
      result(["status": "unavailable"])
      return
    }
    guard
      let arguments = arguments as? [String: Any],
      let transactionIdValue = arguments["transactionId"] as? String,
      let transactionId = UInt64(transactionIdValue),
      transactionId > 0,
      let productId = arguments["productId"] as? String,
      Self.supportedProductIds.contains(productId)
    else {
      result(["status": "rejected"])
      return
    }

    Task { @MainActor in
      for await verificationResult in Transaction.unfinished {
        guard case .verified(let transaction) = verificationResult else {
          continue
        }
        guard
          transaction.id == transactionId,
          transaction.productID == productId
        else {
          continue
        }

        await transaction.finish()
        result(["status": "finished"])
        return
      }

      result(["status": "notFound"])
    }
  }

  @available(iOS 15.0, *)
  private static func technicalRepresentation(
    of transaction: Transaction
  ) -> [String: Any] {
    let revoked = transaction.revocationDate != nil
    let expired = transaction.expirationDate.map { $0 <= Date() } ?? false
    return [
      "transactionId": String(transaction.id),
      "productId": transaction.productID,
      "verified": true,
      "active": !revoked && !expired,
      "revoked": revoked,
      "expired": expired,
    ]
  }
}
