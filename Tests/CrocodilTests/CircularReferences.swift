//
//  CircularReferences.swift
//  Crocodil
//
//  Created by Sergey Kazakov on 29/06/2025.
//

import XCTest
import Crocodil
 
fileprivate extension Dependencies {
    
    // Be aware of circular references. They are possible
    @DependencyEntry private var circularDependencyOne: Int = Dependency[\.circularDependencyTwo] + 1
    @DependencyEntry var circularDependencyTwo: Int = Dependency[\.circularDependencyOne] - 1
    @DependencyEntry var circularDependencyThree: Int = Dependency[\.circularDependencyThree] - 1
}
 
