//
//  AnalyticsEvent.swift
//  Tracker
//
//  Created by Yana Silosieva on 22.04.2025.
//

import AppMetricaCore

enum AnalyticsEvent {
    static func send(event: String, screen: String, item: String? = nil) {
        var parameters: [String: Any] = [
            "event": event,
            "screen": screen
        ]
        if let item = item {
            parameters["item"] = item
        }
        AppMetrica.reportEvent(name: "ui_event", parameters: parameters, onFailure: nil)
    }
}
