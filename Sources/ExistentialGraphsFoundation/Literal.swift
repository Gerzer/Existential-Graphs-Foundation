//
//  Literal.swift
//  Existential Graphs Foundation
//
//  Created by Gabriel Jacoby-Cooper on 4/6/22.
//

#if canImport(SwiftUI)
import SwiftUI
#endif // canImport(SwiftUI)

#if canImport(CoreGraphics)
import CoreGraphics
#else // canImport(CoreGraphics)
import Foundation
import Silica
#endif // canImport(CoreGraphics)

/// A representation of a literal in an existential graph.
public class Literal: GraphObject, GraphElement, Unique, Codable {
	
	private enum CodingKeys: CodingKey {
		
		case character, position
		
	}
	
	/// The character that represents the formal-logic symbol that’s associated with this literal.
	public let character: Character
	
	/// The geometric width of this literal in 2D space.
	public private(set) var width: CGFloat = 40
	
	/// The geometric height of this literal in 2D space.
	public private(set) var height: CGFloat = 40
	
	/// A rectangle that geometrically bounds this literal in 2D space.
	public var frame: CGRect {
		get {
			return CGRect(
				origin: CGPoint(
					x: self.position.x - self.width / 2,
					y: self.position.y - self.height / 2
				),
				size: CGSize(
					width: self.width,
					height: self.height
				)
			)
		}
	}
	
	public var position: CGPoint {
		didSet {
			self.parent.synchronize()
		}
	}
	
	public weak var parent: (any GraphElementContainer)!
	
	public var isSelected: Bool = false {
		didSet {
			self.parent.synchronize()
		}
	}
	
	public var isHighlighted: Bool = false {
		didSet {
			self.parent.synchronize()
		}
	}
	
	public let transform: CGAffineTransform = .identity
	
	#if canImport(SwiftUI)
	public var strokeColor: Color {
		get {
			return self.isHighlighted ? .yellow : (self.isSelected ? .blue : .primary)
		}
	}
	#endif // canImport(SwiftUI)
	
	public lazy var positionTransaction = TransformationTransaction(parent: self, valueKeyPath: \.position)
	
	/// Creates a literal.
	/// - Parameters:
	///   - character: The character to use to represent the formal-logic symbol that’s associated with the literal.
	///   - position: The geometric position of the literal.
	///   - width: The geometric width of the literal.
	///   - height: The geometric height of the literal.
	public init(_ character: Character, position: CGPoint, width: CGFloat? = nil, height: CGFloat? = nil) {
		self.character = character
		self.position = position
		if let width = width {
			self.width = width
		}
		if let height = height {
			self.height = height
		}
	}
	
	public func containsGeometrically(_ point: CGPoint) -> Bool {
		return self.frame.contains(point)
	}
	
}
