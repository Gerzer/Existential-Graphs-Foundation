//
//  TransformationTransaction.swift
//  Existential Graphs Foundation
//
//  Created by Gabriel Jacoby-Cooper on 4/6/22.
//

public struct TransformationTransaction<Parent, TransactionValue> where Parent: AnyObject, TransactionValue: AdditiveArithmetic {
	
	private var parent: Parent
	
	private var baseValue: TransactionValue?
	
	private var valueKeyPath: ReferenceWritableKeyPath<Parent, TransactionValue>
	
	init(parent: Parent, valueKeyPath: ReferenceWritableKeyPath<Parent, TransactionValue>) {
		self.parent = parent
		self.valueKeyPath = valueKeyPath
	}
	
	public mutating func begin() {
		self.baseValue = self.parent[keyPath: self.valueKeyPath]
	}
	
	public func apply(delta: TransactionValue) throws {
		guard let baseValue = self.baseValue else {
			throw TransformationTransactionError.noCurrentTransaction
		}
		self.parent[keyPath: self.valueKeyPath] = baseValue + delta
	}
	
	public mutating func end() {
		self.baseValue = nil
	}
	
	public mutating func cancel() throws {
		guard let baseValue = self.baseValue else {
			throw TransformationTransactionError.noCurrentTransaction
		}
		self.parent[keyPath: self.valueKeyPath] = baseValue
		self.baseValue = nil
	}
	
}

enum TransformationTransactionError: Error {
	
	case noCurrentTransaction
	
}
