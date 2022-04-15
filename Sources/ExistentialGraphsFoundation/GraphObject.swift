//
//  GraphObject.swift
//  Existential Graphs Foundation
//
//  Created by Gabriel Jacoby-Cooper on 4/6/22.
//

import Foundation

/// A class from which all components of an existential graph inherit.
public class GraphObject: Hashable, Identifiable {
	
	/// An identifier type that enables the unique identification of graph objects.
	public struct ID: Hashable {
		
		private let uuid = UUID()
		
		/// The graph object that this identifier identifies.
		/// - Note: This property is stored as a weak reference, so the graph object that it references might already have been deallocated, in which case the value will be `nil`.
		public private(set) weak var object: GraphObject?
		
		init(_ object: GraphObject) {
			self.object = object
		}
		
		public func hash(into hasher: inout Hasher) {
			hasher.combine(self.uuid)
		}
		
	}
	
	public lazy var id = ID(self)
	
	/// The children of this graph object.
	/// - Note: The array will never be empty; rather, if there are no children, then the value of this property will be `nil`.
	public var children: [GraphObject]? {
		get {
			guard let selfAsContainer = self as? GraphElementContainer else {
				return nil
			}
			if selfAsContainer.childLiterals.isEmpty && selfAsContainer.childCuts.isEmpty {
				return nil
			} else {
				return selfAsContainer.childLiterals + selfAsContainer.childCuts
			}
		}
	}
	
	public func hash(into hasher: inout Hasher) {
		hasher.combine(self.id)
	}
	
	public static func == (_ lhs: GraphObject, _ rhs: GraphObject) -> Bool {
		return lhs.hashValue == rhs.hashValue
	}
	
}
