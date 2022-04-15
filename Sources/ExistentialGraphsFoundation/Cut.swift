//
//  Cut.swift
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

/// A representation of a cut in an existential graph.
public class Cut: GraphObject, GraphElement, IterableGraphElementContainer, Unique, Codable {
	
	private enum CodingKeys: CodingKey {
		
		case childLiterals, childCuts, frame, transform
		
	}
	
	/// The direct child literals of this cut.
	/// - Warning: Don’t modify the value of this property manually.
	/// - Remark: Setting this property will automatically invoke ``synchronize()``.
	public var childLiterals: [Literal] {
		didSet {
			self.synchronize()
		}
	}
	
	/// The direct child cuts of this cut.
	/// - Warning: Don’t modify the value of this property manually.
	/// - Remark: Setting this property will automatically invoke ``synchronize()``.
	public var childCuts: [Cut] {
		didSet {
			self.synchronize()
		}
	}
	
	public private(set) var allLiterals: Set<Literal> = []
	
	public private(set) var allCuts: Set<Cut> = []
	
	/// A rectangle that geometrically bounds this cut in 2D space.
	/// - Remark: Setting this property will automatically invoke ``synchronize()``.
	public private(set) var frame: CGRect {
		didSet {
			self.synchronize()
		}
	}
	
	public var position: CGPoint {
		get {
			return self.frame.center
		}
		set {
			self.frame.center = newValue
		}
	}
	
	public weak var parent: (any GraphElementContainer)!
	
	/// A property that indicates whether this cut is currently selected.
	/// - Remark: Setting this property will automatically invoke ``synchronize()``.
	public var isSelected: Bool = false {
		didSet {
			self.synchronize()
		}
	}
	
	/// A property that indicates whether this cut is currently selected.
	/// - Remark: Setting this property will automatically invoke ``synchronize()``.
	public var isHighlighted: Bool = false {
		didSet {
			self.synchronize()
		}
	}
	
	public private(set) var transform: CGAffineTransform
	
	#if canImport(SwiftUI)
	public var strokeColor: Color {
		get {
			return self.isHighlighted ? .yellow : (self.isSelected ? .blue : .primary)
		}
	}
	#endif // canImport(SwiftUI)
	
	#if canImport(SwiftUI)
	/// An appropriate color to use for a fill that’s used to draw this cut on-screen.
	public var fillColor: Color {
		get {
			return self.isSelected ? .blue.opacity(0.2) : .clear
		}
	}
	#endif // canImport(SwiftUI)
	
	var path: CGPath {
		get {
			return CGPath(ellipseIn: self.frame, transform: nil)
		}
	}
	
	public lazy var positionTransaction = TransformationTransaction(parent: self, valueKeyPath: \.position)
	
	/// Creates a cut.
	/// - Parameters:
	///   - childLiterals: The literals to add as direct children of the new cut.
	///   - childCuts: The cuts to add as direct children of the new cut.
	///   - frame: A rectangle that geometrically bounds the cut in 2D space.
	///   - transform: An affine transform to be applied to the geometric representation of the cut.
	public init(childLiterals: [Literal] = [], childCuts: [Cut] = [], frame: CGRect, transform: CGAffineTransform = .identity) {
		self.childLiterals = childLiterals
		self.childCuts = childCuts
		self.frame = frame
		self.transform = transform
	}
	
	public func synchronize() {
		(self.allLiterals, self.allCuts) = Utilities.flatten(literals: self.childLiterals, cuts: self.childCuts)
		self.parent?.synchronize()
	}
	
	/// Checks whether this cut geometrically contains the given point.
	/// - Parameter point: The point to check.
	/// - Returns: `true` if this cut geometrically contains the given point; otherwise `false`.
	/// - Warning: If Core Graphics is unavailable, then this method *always* returns `false`.
	public func containsGeometrically(_ point: CGPoint) -> Bool {
		return self.path.contains(point)
	}
	
	public func containsGeometrically(_ element: any GraphElement) -> Bool {
		return element.isGeometricallyIn(self.path)
	}
	
}
