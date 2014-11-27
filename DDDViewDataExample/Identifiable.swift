//
//  Identifiable.swift
//  DDDViewDataExample
//
//  Created by Christian Tietze on 27.11.14.
//  Copyright (c) 2014 Christian Tietze. All rights reserved.
//

import Foundation

// TODO put this typealias into a helper file
public typealias IntegerId = Int64

public protocol Identifiable {
    var identifier: IntegerId { get }
}