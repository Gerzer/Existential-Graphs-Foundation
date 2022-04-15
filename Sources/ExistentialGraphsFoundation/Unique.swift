//
//  Unique.swift
//  Existential Graphs Foundation
//
//  Created by Gabriel Jacoby-Cooper on 4/6/22.
//

typealias Unique = UniquelyHashable & UniquelyIdentifiable

protocol UniquelyHashable: Hashable {
	
	associatedtype ID
	
	var id: ID { get }
	
}

extension UniquelyHashable where ID: Hashable {
	
	func hash(into hasher: inout Hasher) {
		hasher.combine(self.id)
	}
	
}

protocol UniquelyIdentifiable: Identifiable { }

extension UniquelyIdentifiable {
	
	static func == (_ lhs: Self, _ rhs: Self) -> Bool {
		return lhs.id == rhs.id
	}
	
}
