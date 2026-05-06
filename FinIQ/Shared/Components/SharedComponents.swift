import SwiftUI

struct GlassCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(16)
    }
}

struct PrimaryButton: View {
    let title: String
    let isLoading: Bool
    let action: () -> Void

    init(_ title: String, isLoading: Bool = false, action: @escaping () -> Void) {
        self.title = title
        self.isLoading = isLoading
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Group {
                if isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text(title)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.teal)
            .foregroundStyle(.white)
            .cornerRadius(12)
        }
        .disabled(isLoading)
    }
}

struct AmountText: View {
    let amount: String
    let type: TransactionType
    let currencyCode: String

    init(_ amount: String, type: TransactionType, currencyCode: String = "IDR") {
        self.amount = amount
        self.type = type
        self.currencyCode = currencyCode
    }

    var body: some View {
        Text(formattedAmount)
            .foregroundStyle(color)
            .fontWeight(.semibold)
    }

    private var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode
        if let decimal = Decimal(string: amount) {
            let formatted = formatter.string(from: decimal as NSDecimalNumber) ?? amount
            return type == .expense ? "-\(formatted)" : "+\(formatted)"
        }
        return amount
    }

    private var color: Color {
        switch type {
        case .income: return .green
        case .expense: return .red
        case .transfer: return .blue
        }
    }
}