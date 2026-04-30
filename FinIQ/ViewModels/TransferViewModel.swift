//
//  TransferViewModel.swift
//  FinIQ
//
//  Transfer business logic
//

import Foundation

@MainActor
@Observable
final class TransferViewModel {
    var accounts: [Account] = []
    var isLoading = false
    var errorMessage: String?

    private let accountService = AccountService.shared
    private let transactionService = TransactionService.shared

    func loadAccounts() async {
        isLoading = true
        do {
            accounts = try await accountService.getAccounts()
        } catch let error as APIError {
            errorMessage = error.message
        } catch {
            errorMessage = "Failed to load accounts"
        }
        isLoading = false
    }

    func transfer(
        fromAccountId: String,
        toAccountId: String,
        amount: String,
        note: String?,
        date: String?
    ) async -> Bool {
        isLoading = true
        errorMessage = nil

        do {
            _ = try await transactionService.transfer(
                fromAccountId: fromAccountId,
                toAccountId: toAccountId,
                amount: amount,
                note: note,
                date: date
            )
            isLoading = false
            return true
        } catch let error as APIError {
            errorMessage = error.message
            isLoading = false
            return false
        } catch {
            errorMessage = "Transfer failed"
            isLoading = false
            return false
        }
    }
}