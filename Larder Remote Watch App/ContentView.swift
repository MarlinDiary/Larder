//
//  ContentView.swift
//  Larder Remote Watch App
//
//  Created by Marlin on 19/11/2025.
//

import SwiftUI
import Combine
import WatchConnectivity

struct ContentView: View {
    @StateObject private var sender = RemoteStepSender()
    @State private var isSending = false

    var body: some View {
        VStack(spacing: 12) {
            Text("Next Step")
                .font(.headline)

            Button {
                isSending = true
                sender.sendNextStep()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    isSending = false
                }
            } label: {
                Image(systemName: isSending ? "arrow.right.circle.fill" : "arrow.right.circle")
                    .font(.system(size: 42))
                    .foregroundStyle(isSending ? .green : .blue)
            }
            .buttonStyle(.plain)
            .handGestureShortcut(.primaryAction)

            if let date = sender.lastSentDate {
                Text("Sent \(date, style: .time)")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}

final class RemoteStepSender: NSObject, ObservableObject {
    @Published private(set) var lastSentDate: Date?
    private var session: WCSession?

    override init() {
        super.init()
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
            self.session = session
        }
    }

    func sendNextStep() {
        guard let session, session.isReachable else { return }
        session.sendMessage(["action": "nextStep"], replyHandler: nil, errorHandler: nil)
        lastSentDate = Date()
    }
}

extension RemoteStepSender: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {}
}
