import SwiftUI

struct NetworkLogView: View {
    @State private var logs: [NetworkLogger.NetworkLogEntry] = []
    @State private var selectedLog: NetworkLogger.NetworkLogEntry?
    @State private var showDetail = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(logs) { log in
                    Button {
                        selectedLog = log
                        showDetail = true
                    } label: {
                        HStack {
                            statusIcon(for: log)
                                .foregroundStyle(color(for: log))

                            VStack(alignment: .leading, spacing: 4) {
                                Text("\(log.method) \(pathFrom(url: log.url))")
                                    .font(.system(.subheadline, design: .monospaced))
                                    .foregroundStyle(.primary)

                                Text(log.formattedTimestamp)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            if let duration = log.duration {
                                Text("\(String(format: "%.0f", duration * 1000))ms")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("Network Logs")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Clear") {
                        NetworkLogger.shared.clear()
                        logs = []
                    }
                }
            }
            .sheet(isPresented: $showDetail) {
                if let log = selectedLog {
                    NetworkLogDetailView(log: log)
                }
            }
            .onAppear {
                logs = NetworkLogger.shared.entries
            }
            .refreshable {
                logs = NetworkLogger.shared.entries
            }
        }
    }

    @ViewBuilder
    private func statusIcon(for log: NetworkLogger.NetworkLogEntry) -> some View {
        if log.error != nil {
            Image(systemName: "xmark.circle.fill")
        } else if let code = log.statusCode {
            if code >= 200 && code < 300 {
                Image(systemName: "checkmark.circle.fill")
            } else if code >= 400 {
                Image(systemName: "exclamationmark.circle.fill")
            } else {
                Image(systemName: "arrow.clockwise.circle.fill")
            }
        } else {
            Image(systemName: "questionmark.circle.fill")
        }
    }

    private func color(for log: NetworkLogger.NetworkLogEntry) -> Color {
        if log.error != nil {
            return .red
        }
        guard let code = log.statusCode else { return .secondary }
        if code >= 200 && code < 300 { return .green }
        if code >= 400 { return .red }
        return .secondary
    }

    private func pathFrom(url: String) -> String {
        guard let urlObj = URL(string: url) else { return url }
        return urlObj.path
    }
}

struct NetworkLogDetailView: View {
    let log: NetworkLogger.NetworkLogEntry
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Summary
                    Group {
                        LabeledContent("Method", value: log.method)
                        LabeledContent("URL", value: log.url)
                        LabeledContent("Status", value: log.statusCode.map { "\($0)" } ?? "N/A")
                        LabeledContent("Duration", value: log.duration.map { "\(String(format: "%.2f", $0 * 1000))ms" } ?? "N/A")
                    }
                    .font(.subheadline)

                    Divider()

                    // Request Body
                    if let body = log.requestBodyString {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Request Body")
                                .font(.headline)
                            Text(body)
                                .font(.system(.caption, design: .monospaced))
                                .padding()
                                .background(Color(.secondarySystemBackground))
                                .cornerRadius(8)
                        }
                    }

                    // Response Body
                    if let body = log.responseBodyString {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Response Body")
                                .font(.headline)
                            Text(body)
                                .font(.system(.caption, design: .monospaced))
                                .padding()
                                .background(Color(.secondarySystemBackground))
                                .cornerRadius(8)
                        }
                    }

                    // Error
                    if let error = log.error {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Error")
                                .font(.headline)
                            Text(error)
                                .font(.system(.caption, design: .monospaced))
                                .foregroundStyle(.red)
                                .padding()
                                .background(Color.red.opacity(0.1))
                                .cornerRadius(8)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Request Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}