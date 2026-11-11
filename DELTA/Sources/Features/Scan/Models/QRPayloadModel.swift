import Foundation

/// Represents the inspected outcome of a scanned QR code payload.
/// Designed for safe inspection without executing external URLs or automated payment actions.
public struct ParsedQRPayload: Equatable, Identifiable {
    public var id: String { referenceID ?? rawPayload }

    public enum PayloadType: String, Equatable {
        case upi = "UPI Expense QR"
        case generic = "General Scan Reference"
    }

    public let rawPayload: String
    public let type: PayloadType
    public let payeeAddress: String?     // 'pa' in UPI (Payee VPA / address)
    public let payeeName: String?        // 'pn' in UPI (Payee merchant/person name)
    public let amount: Decimal?          // 'am' in UPI (Transaction amount)
    public let transactionNote: String?  // 'tn' in UPI (Purpose / note)
    public let referenceID: String?      // 'tr' in UPI (Transaction tracking reference)
    public let currency: String?         // 'cu' in UPI (Currency, e.g. INR)

    public init(
        rawPayload: String,
        type: PayloadType,
        payeeAddress: String? = nil,
        payeeName: String? = nil,
        amount: Decimal? = nil,
        transactionNote: String? = nil,
        referenceID: String? = nil,
        currency: String? = nil
    ) {
        self.rawPayload = rawPayload
        self.type = type
        self.payeeAddress = payeeAddress
        self.payeeName = payeeName
        self.amount = amount
        self.transactionNote = transactionNote
        self.referenceID = referenceID
        self.currency = currency
    }

    /// Display title for the payee or detected source
    public var displayTitle: String {
        if let pn = payeeName, !pn.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return pn
        }
        if let pa = payeeAddress, !pa.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return pa
        }
        return "Scanned Expense"
    }
}

/// Errors occurring during QR payload parsing and validation
public enum QRParseError: LocalizedError, Equatable {
    case emptyPayload
    case malformedPayload(String)
    case unsupportedFormat(String)

    public var errorDescription: String? {
        switch self {
        case .emptyPayload:
            return "QR payload is blank or unreadable."
        case .malformedPayload(let detail):
            return "Malformed QR payload: \(detail)"
        case .unsupportedFormat(let detail):
            return "Unsupported QR format: \(detail)"
        }
    }
}

/// Pure functional parser and validator for QR payloads.
/// Enforces financial safety: parses query parameters without executing links or payment commands.
public struct QRPayloadParser {

    /// Parses and validates a raw QR string.
    /// Handles both `upi://pay?...` specifications and generic non-executable reference payloads.
    public static func parse(payload: String) -> Result<ParsedQRPayload, QRParseError> {
        let trimmed = payload.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            return .failure(.emptyPayload)
        }

        // 1. UPI Payload Detection
        if trimmed.lowercased().hasPrefix("upi://pay") {
            return parseUPIPayload(raw: trimmed)
        }

        // 2. Generic Safe Text Payload (Strictly non-executable)
        return parseGenericPayload(raw: trimmed)
    }

    private static func parseUPIPayload(raw: String) -> Result<ParsedQRPayload, QRParseError> {
        // Find query string delimiter
        guard let questionMarkIndex = raw.firstIndex(of: "?") else {
            return .failure(.malformedPayload("Missing UPI parameter query delimiter '?'"))
        }

        let queryString = String(raw[raw.index(after: questionMarkIndex)...])
        guard !queryString.isEmpty else {
            return .failure(.malformedPayload("Empty UPI parameter query string"))
        }

        var params: [String: String] = [:]
        let pairs = queryString.components(separatedBy: "&")
        for pair in pairs {
            let keyValue = pair.components(separatedBy: "=")
            if keyValue.count >= 2 {
                let key = keyValue[0].trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
                let rawValue = keyValue.dropFirst().joined(separator: "=")
                let decodedValue = rawValue
                    .replacingOccurrences(of: "+", with: " ")
                    .removingPercentEncoding ?? rawValue
                params[key] = decodedValue
            }
        }

        // Extract and validate UPI fields
        let payeeAddress = params["pa"]?.trimmingCharacters(in: .whitespacesAndNewlines)
        let payeeName = params["pn"]?.trimmingCharacters(in: .whitespacesAndNewlines)
        let note = params["tn"]?.trimmingCharacters(in: .whitespacesAndNewlines)
        let referenceID = params["tr"]?.trimmingCharacters(in: .whitespacesAndNewlines)
            ?? ("UPI-" + String(Int.random(in: 10000000...99999999)))
        let currency = params["cu"]?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "INR"

        // Validate amount if present
        var parsedAmount: Decimal? = nil
        if let amString = params["am"]?.trimmingCharacters(in: .whitespacesAndNewlines), !amString.isEmpty {
            // Clean decimal string
            let sanitized = amString.replacingOccurrences(of: ",", with: ".")
            if let decimalValue = Decimal(string: sanitized), decimalValue >= 0 {
                parsedAmount = decimalValue
            }
        }

        // Require at least a payee address or payee name for valid UPI
        guard (payeeAddress != nil && !payeeAddress!.isEmpty) || (payeeName != nil && !payeeName!.isEmpty) else {
            return .failure(.malformedPayload("UPI QR lacks both payee address (pa) and payee name (pn)"))
        }

        let parsed = ParsedQRPayload(
            rawPayload: raw,
            type: .upi,
            payeeAddress: payeeAddress,
            payeeName: payeeName,
            amount: parsedAmount,
            transactionNote: note,
            referenceID: referenceID,
            currency: currency
        )
        return .success(parsed)
    }

    private static func parseGenericPayload(raw: String) -> Result<ParsedQRPayload, QRParseError> {
        // Disallow arbitrary executable javascript/data URIs
        let lower = raw.lowercased()
        if lower.hasPrefix("javascript:") || lower.hasPrefix("data:") {
            return .failure(.unsupportedFormat("Potentially unsafe payload URI scheme rejected"))
        }

        // Sanitize display text to maximum 256 characters for reference safety
        let truncated = String(raw.prefix(256))
        let refID = "SCAN-" + String(abs(raw.hashValue) % 100000000)

        let parsed = ParsedQRPayload(
            rawPayload: raw,
            type: .generic,
            payeeAddress: nil,
            payeeName: "Scanned QR Reference",
            amount: nil,
            transactionNote: truncated,
            referenceID: refID,
            currency: nil
        )
        return .success(parsed)
    }
}

