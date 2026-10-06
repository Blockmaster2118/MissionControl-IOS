//
//  ShareViewController.swift
//  MissionControl
//

import UIKit
import UniformTypeIdentifiers

/// Accepts a URL or text and drops it in the App Group inbox for the app to attach to a mission.
final class ShareViewController: UIViewController {
    private let statusLabel = UILabel()
    private var hasStarted = false

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        statusLabel.text = "Saving to MissionControl…"
        statusLabel.font = .preferredFont(forTextStyle: .headline)
        statusLabel.textAlignment = .center
        statusLabel.numberOfLines = 0
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(statusLabel)
        NSLayoutConstraint.activate([
            statusLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            statusLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            statusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24)
        ])
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard !hasStarted else { return }
        hasStarted = true
        Task { await importBrief() }
    }

    private func importBrief() async {
        let item = extensionContext?.inputItems.first as? NSExtensionItem
        var content: String?
        for provider in item?.attachments ?? [] {
            if provider.hasItemConformingToTypeIdentifier(UTType.url.identifier),
               let value = try? await provider.loadItem(forTypeIdentifier: UTType.url.identifier), let url = value as? URL {
                content = url.absoluteString
                break
            }
            if provider.hasItemConformingToTypeIdentifier(UTType.plainText.identifier),
               let value = try? await provider.loadItem(forTypeIdentifier: UTType.plainText.identifier), let text = value as? String {
                content = text
                break
            }
        }

        guard let content, !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            statusLabel.text = "MissionControl can only import links and text."
            try? await Task.sleep(nanoseconds: 1_200_000_000)
            extensionContext?.cancelRequest(withError: NSError(domain: "MissionControlShare", code: 1))
            return
        }

        guard SharedStore.isConfigured else {
            statusLabel.text = "App Group not set up.\nCheck SharedStore.groupID and this target's entitlements."
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            extensionContext?.cancelRequest(withError: NSError(domain: "MissionControlShare", code: 2))
            return
        }

        let title = item?.attributedContentText?.string ?? String(content.prefix(40))
        let saved = SharedStore.save(SharedBrief(title: title, content: content))   // duplicates are ignored
        let alreadyWaiting = SharedStore.pendingBriefs().contains { $0.content == content }
        statusLabel.text = saved ? "Saved to MissionControl" : (alreadyWaiting ? "Already saved in MissionControl" : "Couldn't save. Check the App Group.")
        try? await Task.sleep(nanoseconds: 700_000_000)
        extensionContext?.completeRequest(returningItems: nil)
    }
}
