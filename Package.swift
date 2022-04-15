// swift-tools-version: 5.6

import PackageDescription

let package = Package(
	name: "Existential Graphs Foundation",
	platforms: [
		.macOS(.v10_15),
		.iOS(.v13),
		.tvOS(.v13),
		.watchOS(.v6)
	],
	products: [
		.library(
			name: "ExistentialGraphsFoundation",
			targets: [
				"ExistentialGraphsFoundation"
			]
		),
	],
	dependencies: [
		.package(
			url: "https://github.com/PureSwift/Silica.git",
			branch: "master"
		),
		.package(
			url: "https://github.com/Gerzer/LogicParser.git",
			from: "1.0.0"
		)
	],
	targets: [
		.target(
			name: "ExistentialGraphsFoundation",
			dependencies: [
				.product(
					name: "Silica",
					package: "Silica",
					condition: .when(
						platforms: [
							.linux
						]
					)
				),
				.product(
					name: "LogicParser",
					package: "LogicParser"
				)
			]
		)
	]
)
