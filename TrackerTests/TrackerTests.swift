//
//  TrackerTests.swift
//  TrackerTests
//
//  Created by Yana Silosieva on 30.04.2025.
//

import Testing
import XCTest
import SnapshotTesting
@testable import Tracker

final class TrackerTests: XCTestCase {
    
    func testViewController() {
        let vc = TrackersViewController()
        let nav = UINavigationController(rootViewController: vc)
        nav.overrideUserInterfaceStyle = .dark
        
        _ = nav.view
        nav.view.frame = UIScreen.main.bounds
        nav.view.layoutIfNeeded()
        
        assertSnapshot(of: nav, as: .image)
    }
    
    func testTrackersScreenLight() throws {
        let vc = TrackersViewController()
        assertSnapshots(of: vc, as: [.image(traits: .init(userInterfaceStyle: .light))])
    }
    
    func testTrackersScreenDark() throws {
        let vc = TrackersViewController()
        assertSnapshots(of: vc, as: [.image(traits: .init(userInterfaceStyle: .dark))])
    }
}
