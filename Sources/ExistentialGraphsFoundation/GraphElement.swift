//
//  GraphElement.swift
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

/// The protocol to which all graph objects that can serve as leaves conform.
public protocol GraphElement: AnyObject, Bounded {
	
	/// An identifier that uniquely identifies this instance.
	var id: ObjectIdentifier { get }
	
	/// The geometric position of this graph element in 2D space.
	var position: CGPoint { get set }
	
	/// The container that contains this graph element.
	/// - Warning: Don’t modify the value of this property manually.
	var parent: (any GraphElementContainer)! { get set }
	
	/// A property that indicates whether this graph element is currently selected.
	///
	/// The precise meaning of the value of this property may differ between different use-cases; in other words, you may interpret this property in any manner.
	var isSelected: Bool { get set }
	
	/// A property that indicates whether this graph element is currently highlighted.
	///
	/// The precise meaning of the value of this property may differ between different use-cases; in other words, you may interpret this property in any manner.
	var isHighlighted: Bool { get set }
	
	/// A geometric transform that’s applied to the visual/geometric representation of this graph element.
	var transform: CGAffineTransform { get }
	
	#if canImport(SwiftUI)
	/// An appropriate color to use for a stoke that’s used to draw this graph element on-screen.
	var strokeColor: Color { get }
	#endif // canImport(SwiftUI)
	
	/// Removes this graph element from its parent container.
	func removeFromParent()
	
	/// Checks if the given path is geometrically interior to this graph element.
	/// - Parameter path: The path to check.
	/// - Returns: `true` if the given path is interior to this graph element; otherwise, `false`.
	func isGeometricallyIn(_ path: CGPath) -> Bool
	
	/// Checks whether this graph element geometrically contains the given point.
	/// - Parameter point: The point to check.
	/// - Returns: `true` if this graph element geometrically contains the given point; otherwise `false`.
	func containsGeometrically(_ point: CGPoint) -> Bool
	
}

public protocol GraphElementContainer: AnyObject, Bounded {
	
	/// An identifier that uniquely identifies this instance.
	var id: GraphObject.ID { get }
	
	/// The container that contains this container.
	var parent: (any GraphElementContainer)! { get }
	
	/// The direct child literals of this container.
	/// - Warning: Don’t modify the value of this property manually.
	var childLiterals: [Literal] { get set }
	
	/// The direct child cuts of this container.
	/// - Warning: Don’t modify the value of this property manually.
	var childCuts: [Cut] { get set }
	
	/// Synchronizes changes to this container with its parent.
	func synchronize()
	
	/// Inserts the given graph element as a direct child of this container.
	/// - Parameter child: The graph element to insert.
	func insert(_ child: any GraphElement)
	
	/// Removes the given graph element from this container.
	///
	/// The given graph element must be a direct child of this container.
	/// - Parameter child: The graph element to remove.
	/// - Returns: `true` if the given element was present in this container and was removed successfully; otherwise, `false`.
	@discardableResult func remove(_ child: any GraphElement) -> Bool
	
	/// Checks whether this container contains the given graph element in its tree.
	///
	/// The given graph element may be located at a multiply nested level relative to this container; in other words, this method is recursive. No geometric checks are performed.
	/// - Parameter child: The graph element to check.
	/// - Returns: `true` if this container contains the given graph element in its tree; otherwise, `false`.
	func contains(_ child: any GraphElement) -> Bool
	
	/// Checks whether this container geometrically contains the given graph element.
	/// - Parameter element: The graph element to check.
	/// - Returns: `true` if this container geometrically contains the given graph element; otherwise, `false`.
	func containsGeometrically(_ element: any GraphElement) -> Bool
	
}

/// A protocol that permits that its conforming types support iteration over their constituent graph elements.
public protocol IterableAbstractGraphElementContainer: Sequence where Iterator == GraphElementContainerIterator {
	
	/// A flattened set that contains all of this container’s constituent literals from all nested levels.
	var allLiterals: Set<Literal> { get }
	
	/// A flattened set that contains all of this container’s constituent cuts from all nested levels.
	var allCuts: Set<Cut> { get }
	
}

/// A container that supports iteration over its constituent graph elements.
typealias IterableGraphElementContainer = GraphElementContainer & IterableAbstractGraphElementContainer

/// An iterator that enables iteration over a homogenous sequence of literals and cuts.
public struct GraphElementContainerIterator: IteratorProtocol {
	
	private let literals: [Literal]
	
	private let cuts: [Cut]
	
	private var offset = 0
	
	fileprivate init(literals: [Literal], cuts: [Cut]) {
		self.literals = literals
		self.cuts = cuts
	}
	
	public mutating func next() -> (any GraphElement)? {
		if self.offset >= self.literals.count + self.cuts.count {
			return nil
		}
		defer {
			self.offset += 1
		}
		if self.offset < self.literals.count {
			return self.literals[self.offset]
		} else {
			return self.cuts[self.offset - self.literals.count]
		}
	}
	
}

fileprivate class ShallowGraphElementContainer: IterableAbstractGraphElementContainer {
	
	let allLiterals: Set<Literal>
	
	let allCuts: Set<Cut>
	
	init(from container: any GraphElementContainer) {
		self.allLiterals = Set(container.childLiterals)
		self.allCuts = Set(container.childCuts)
	}
	
}

extension GraphElement {
	
	public func removeFromParent() {
		self.parent.remove(self)
	}
	
	/// Checks if the given path is geometrically interior to this graph element.
	/// - Parameter path: The path to check.
	/// - Returns: `true` if the given path is interior to this graph element; otherwise, `false`.
	/// - Warning: If Core Graphics is unavailable, then this method *always* returns `false`.
	public func isGeometricallyIn(_ path: CGPath) -> Bool {
		return self.frame
			.applying(self.transform)
			.allVerticesSatisfy { (vertex) in
				return path.contains(vertex)
			}
	}
	
}

extension GraphElementContainer {
	
	/// A shallow representation of this container that supports iteration over its constituent graph elements.
	///
	/// The shallow representation still supports iteration over graph elements that are at a nested level relative to this container.
	public var shallow: some IterableAbstractGraphElementContainer {
		return ShallowGraphElementContainer(from: self)
	}
	
	public func insert(_ child: any GraphElement) {
		if let oldParent = child.parent {
			let removalDidSucceed = oldParent.remove(child)
			assert(removalDidSucceed)
		}
		child.parent = self
		if let literal = child as? Literal {
			self.childLiterals.append(literal)
		} else if let cut = child as? Cut {
			self.childCuts.append(cut)
		} else {
			fatalError("New child is neither a literal nor a cut")
		}
		self.synchronize()
	}
	
	public func remove(_ child: any GraphElement) -> Bool {
		if let literal = child as? Literal {
			guard let index = self.childLiterals.firstIndex(of: literal) else {
				print("[GraphElementContainer remove(_:)] The specified literal isn’t a direct child of this container")
				return false
			}
			self.childLiterals.remove(at: index)
		} else if let cut = child as? Cut {
			guard let index = self.childCuts.firstIndex(of: cut) else {
				print("[GraphElementContainer remove(_:)] The specified cut isn’t a direct child of this container")
				return false
			}
			self.childCuts.remove(at: index)
		}
		child.parent = nil
		self.synchronize()
		return true
	}
	
	public func contains(_ child: any GraphElement) -> Bool {
		if let literal = child as? Literal, self.childLiterals.contains(literal) {
			return true
		} else if let cut = child as? Cut, self.childCuts.contains(cut) {
			return true
		}
		for cut in self.childCuts {
			if cut.contains(child) {
				return true
			}
		}
		return false
	}
	
}

extension IterableAbstractGraphElementContainer {
	
	public func makeIterator() -> GraphElementContainerIterator {
		return GraphElementContainerIterator(literals: Array(self.allLiterals), cuts: Array(self.allCuts))
	}
	
}
