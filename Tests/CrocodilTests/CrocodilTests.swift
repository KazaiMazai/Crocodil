import XCTest
import Crocodil
 
extension Dependencies {
    @DependencyEntry var intValue: Int = 1
    @DependencyEntry var anotherIntValue: Int = Dependency[\.intValue] + 1
    @DependencyEntry var oneMoreIntValue: Int = Dependency[\.anotherIntValue] + 1
}
 
final class CrocodilTests: XCTestCase {
    @Dependency(\.intValue) var value
    
    func test_whenDependencyProvided_CanBeAccessedViaProperyWrapper() {
        XCTAssertEqual(value, 1)
    }
    
    func test_whenReadAndWriteValue_NoDeadlockOccurs() {
        XCTAssertEqual(Dependency[\.intValue], 1)
        
        Dependencies.inject(\.intValue, Dependency[\.intValue] + 1)
        XCTAssertEqual(Dependency[\.intValue], 2)
    }
    
    func test_whenSettingDepenency_DependencyUpdated() {
        Dependencies.inject(\.intValue, 2)
        XCTAssertEqual(Dependency[\.intValue], 2)
    }
}
