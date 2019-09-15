//
//  Bugfender.swift
//  Bugfender
//
//  This is a helper file for easier logging with Swift.
//  Copyright © 2017 Bugfender. All rights reserved.
//
import Foundation

public func BFLog(_ format: String, _ args: CVarArg..., tag: String? = nil, level: BFLogLevel = .default, filename: String = #file, line: Int = #line, funcname: String = #function)
{
	let message = String(format: format, arguments: args)
	Bugfender.log(lineNumber: line, method: funcname, file: filename, level: level, tag: tag, message: message)
}
