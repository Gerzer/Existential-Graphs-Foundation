//
//  Bounded.swift
//  Existential Graphs Foundation
//
//  Created by Gabriel Jacoby-Cooper on 4/6/22.
//

#if canImport(CoreGraphics)
import CoreGraphics
#else // canImport(CoreGraphics)
import Foundation
import Silica
#endif // canImport(CoreGraphics)

/// A protocol that ensures that its conforming types can be represented within a rectangle in 2D space.
public protocol Bounded {
	
	/// The frame that bounds the representation of this instance in 2D space.
	var frame: CGRect { get }
	
	/// Checks whether this instance geometrically intersects with the given instance in 2D space.
	/// - Parameter other: The instance to check.
	/// - Returns: `true` if this instance intersects with the given instance in 2D space; otherwise, `false`.
	func intersectsGeometrically(_ other: any Bounded) -> Bool
	
}

extension Bounded {
	
	public func intersectsGeometrically(_ other: any Bounded) -> Bool {
		return self.frame.intersects(other.frame)
	}
	
}
