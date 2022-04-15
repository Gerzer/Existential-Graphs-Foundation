//
//  Utilities.swift
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

enum Utilities {
	
	static func flatten(literals originalLiterals: [Literal], cuts originalCuts: [Cut]) -> (literals: Set<Literal>, cuts: Set<Cut>) {
		var literals = Set(originalLiterals)
		var cuts = Set(originalCuts)
		self.flatten(literals: &literals, cuts: &cuts)
		return (literals: literals, cuts: cuts)
	}
	
	static func flatten(literals: inout Set<Literal>, cuts: inout Set<Cut>) {
		for cut in cuts {
			let oldCutsCount = cuts.count
			literals.formUnion(cut.childLiterals)
			cuts.formUnion(cut.childCuts)
			if cuts.count > oldCutsCount {
				self.flatten(literals: &literals, cuts: &cuts)
			}
		}
	}
	
}

extension CGPoint: AdditiveArithmetic {
	
	public static func + (_ lhs: CGPoint, _ rhs: CGPoint) -> CGPoint {
		return CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
	}
	
	public static func - (_ lhs: CGPoint, _ rhs: CGPoint) -> CGPoint {
		return CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
	}
	
}

extension CGRect {
	
	var center: CGPoint {
		get {
			return self.origin + CGPoint(x: self.width / 2, y: self.height / 2)
		}
		set {
			self.origin.x = newValue.x - self.width / 2
			self.origin.y = newValue.y - self.height / 2
		}
	}
	
	func allVerticesSatisfy(_ predicate: (CGPoint) throws -> Bool) rethrows -> Bool {
		let minXMinYDoesSatisfy = try predicate(CGPoint(x: self.minX, y: self.minY))
		let minXMaxYDoesSatisfy = try predicate(CGPoint(x: self.minX, y: self.maxY))
		let maxXMinYDoesSatisfy = try predicate(CGPoint(x: self.maxX, y: self.minY))
		let maxXMaxYDoesSatisfy = try predicate(CGPoint(x: self.maxX, y: self.maxY))
		return minXMinYDoesSatisfy && minXMaxYDoesSatisfy && maxXMinYDoesSatisfy && maxXMaxYDoesSatisfy
	}
	
}

#if !canImport(CoreGraphics)
extension CGRect {
	
	/// Applies an affine transform to this rectangle.
	/// - Warning: This implementation is used only when Core Graphics is unavailable and is included merely to preserve source compatibility with Core Graphics; it always returns `self` unmodified and doesn’t actually perform any computations.
	func applying(_: CGAffineTransform) -> CGRect {
		print("[CGRect applying(_:)] Warning: Invoked a source-compatibility method, which doesn’t actually perform any computations")
		return self
	}
	
}

extension CGPath {
	
	/// Creates a path of an ellipse.
	/// - Parameters:
	///   - rect: A rectangle that bounds the ellipse.
	///   - transform: An optional pointer to a `CGAffineTransform` instance.
	/// - Warning: This implementation is used only when Core Graphics is unavailable. The `transform` parameter is included merely to preserve source compatibility with Core Graphics; its value is ignored.
	init(ellipseIn rect: CGRect, transform: UnsafePointer<CGAffineTransform>?) {
		if transform != nil {
			print("[CGPath init(ellipseIn:transform:)] Warning: Passed a non-nil value to a source-compatibility parameter, which will be ignored")
		}
		self.init()
		self.addEllipse(in: rect)
	}
	
	/// Returns whether the specified point is interior to this path.
	/// - Warning: This implementation is used only when Core Graphics is unavailable and is included merely to preserve source compatibiility with Core Graphics; it always returns `false` and doesn’t actually perform any computations.
	func contains(_: CGPoint, using _: CGPathFillRule = .winding, transform _: CGAffineTransform = .identity) -> Bool {
		print("[CGPath contains(_:using:transform:)] Warning: Invoked a source-compatibility method, which doesn’t actually perform any computations")
		return false
	}
	
}

extension CGAffineTransform: Codable {
	
	enum CodingKeys: CodingKey {
		
		case a, b, c, d, tx, ty
		
	}
	
	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		let a = try container.decode(CGFloat.self, forKey: .a)
		let b = try container.decode(CGFloat.self, forKey: .b)
		let c = try container.decode(CGFloat.self, forKey: .c)
		let d = try container.decode(CGFloat.self, forKey: .d)
		let tx = try container.decode(CGFloat.self, forKey: .tx)
		let ty = try container.decode(CGFloat.self, forKey: .ty)
		self.init(a: a, b: b, c: c, d: d, tx: tx, ty: ty)
	}
	
	public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(self.a, forKey: .a)
		try container.encode(self.b, forKey: .b)
		try container.encode(self.c, forKey: .c)
		try container.encode(self.d, forKey: .d)
		try container.encode(self.tx, forKey: .tx)
		try container.encode(self.ty, forKey: .ty)
	}
	
}
#endif
