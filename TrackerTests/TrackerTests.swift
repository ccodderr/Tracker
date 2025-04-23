//
//  TrackerTests.swift
//  TrackerTests
//
//  Created by Yana Silosieva on 23.04.2025.
//

import Testing
import XCTest
import SnapshotTesting
@testable import Tracker

final class TrackerTests: XCTestCase {
    
    func testViewController() {
        let vc = TrackersViewController()
        let nav = UINavigationController(rootViewController: vc)
        nav.overrideUserInterfaceStyle = .light
        
        _ = nav.view
        
        assertSnapshot(of: nav, as: .image)
    }
}
