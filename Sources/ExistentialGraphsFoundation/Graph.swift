//
//  Graph.swift
//  Existential Graphs Foundation
//
//  Created by Gabriel Jacoby-Cooper on 4/6/22.
//

import LogicParser

#if canImport(CoreGraphics)
import CoreGraphics
#else // canImport(CoreGraphics)
import Foundation
import Silica
#endif // canImport(CoreGraphics)

/// An existential graph.
public class Graph: GraphObject, IterableGraphElementContainer, Sequence, Codable {
	
	private enum CodingKeys: CodingKey {
		
		case childLiterals, childCuts
		
	}
	
	/// The container that contains this container.
	/// - Warning: Don’t reference this property on ``Graph`` instances because doing so might cause a crash.
	/// - Important: ``Graph`` instances don’t have parents, so this property should always be `nil`.
	public private(set) var parent: (any GraphElementContainer)!
	
	public var childLiterals: [Literal] {
		didSet {
			self.synchronize()
		}
	}
	
	public var childCuts: [Cut] {
		didSet {
			self.synchronize()
		}
	}
	
	public private(set) var allLiterals: Set<Literal> = []
	
	public private(set) var allCuts: Set<Cut> = []
	
	public let frame: CGRect = .infinite
	
	private(set) var isLoading: Bool = false
	
	/// A custom handler that’s executed whenever ``synchronize()`` is invoked.
	public var synchronizationHandler: (() -> Void)? = nil
	
	/// Creates an empty existential graph.
	/// - Parameter isLoading: A flag that indicates whether the backend filesystem representation is still loading into system memory.
	public init(isLoading: Bool = false) {
		self.childLiterals = []
		self.childCuts = []
		self.isLoading = isLoading
	}
	
	/// Sets the ``GraphElement/parent`` property of the given graph element to a reference to a given container.
	/// - Parameters:
	///   - element: The graph element the ``GraphElement/parent`` property of which to set.
	///   - parent: The container a reference to which to set the ``GraphElement/parent`` property of the given graph element.
	public static func setParent(of element: any GraphElement, to parent: any GraphElementContainer) {
		element.parent = parent
		if let cut = element as? Cut {
			for childElement in cut.shallow {
				self.setParent(of: childElement, to: cut)
			}
		}
	}
	
	/// Synchronizes changes to the children of this graph with its internal representation of those children.
	public func synchronize() {
		(self.allLiterals, self.allCuts) = Utilities.flatten(literals: self.childLiterals, cuts: self.childCuts)
		self.synchronizationHandler?()
	}
	
	public func containsGeometrically(_: any GraphElement) -> Bool {
		return true
	}
	
	/// Recursively sets the ``GraphElement/isHighlighted`` property of all of the children of this graph to `false`.
	public func removeAllHighlighting() {
		for element in self {
			element.isHighlighted = false
		}
	}
	
}
