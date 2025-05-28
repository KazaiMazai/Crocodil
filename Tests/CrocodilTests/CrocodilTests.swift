import XCTest
import Crocodil
 
extension Dependencies {
    @DependencyEntry var intValue: Int = 1
    @DependencyEntry var anotherIntValue: Int = Dependency[\.intValue] + 1
    @DependencyEntry var oneMoreIntValue: Int = Dependencies[\.anotherIntValue] + 1
}
 
final class CrocodilTests: XCTestCase {
    @Dependency(\.intValue) var value
    
    func test_whenDependencyProvided_CanBeAccessedViaProperyWrapper() {
        XCTAssertEqual(value, 1)
    }
    
    func test_whenReadAndWriteToSharedStoresValue_NoDeadlockOccurs() {
        XCTAssertEqual(Dependency[\.intValue], 1)
        
        Dependencies[\.intValue] = Dependencies[\.intValue] + 1
        XCTAssertEqual(Dependencies[\.intValue], 2)
    }
    
    func test_whenSettingDepenency_DepencencyUpdated() {
        Dependencies[\.intValue] = 2
        XCTAssertEqual(Dependencies[\.intValue], 2)
    }
}
