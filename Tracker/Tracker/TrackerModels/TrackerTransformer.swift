//
//  TrackerTransformer.swift
//  Tracker
//
//  Created by Yana Silosieva on 12.04.2025.
//

import Foundation

@objc
final class TrackerTransformer: ValueTransformer {
    override class func transformedValueClass() -> AnyClass { NSData.self }
    override class func allowsReverseTransformation() -> Bool { true }
    
    override func transformedValue(_ value: Any?) -> Any? {
        guard let tracker = value as? [Tracker] else { return nil }
        return try? JSONEncoder().encode(tracker)
    }

    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? NSData else { return nil }
        return try? JSONDecoder().decode([Tracker].self, from: data as Data)
    }
    
    static func register() {
        ValueTransformer.setValueTransformer(
            TrackerTransformer(),
            forName: NSValueTransformerName(
                rawValue: String(describing: TrackerTransformer.self)
            )
        )
    }
}
