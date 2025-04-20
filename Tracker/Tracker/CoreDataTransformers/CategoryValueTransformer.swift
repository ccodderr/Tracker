//
//  CategoryValueTransformer.swift
//  Tracker
//
//  Created by Yana Silosieva on 20.04.2025.
//

import Foundation

@objc
final class CategoryValueTransformer: ValueTransformer {
    override class func transformedValueClass() -> AnyClass { NSData.self }
    override class func allowsReverseTransformation() -> Bool { true }
    
    override func transformedValue(_ value: Any?) -> Any? {
        guard let category = value as? Category else { return nil }
        return try? JSONEncoder().encode(category)
    }

    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? NSData else { return nil }
        return try? JSONDecoder().decode(Category.self, from: data as Data)
    }
    
    static func register() {
        ValueTransformer.setValueTransformer(
            CategoryValueTransformer(),
            forName: NSValueTransformerName(rawValue: String(describing: CategoryValueTransformer.self))
        )
    }
}
