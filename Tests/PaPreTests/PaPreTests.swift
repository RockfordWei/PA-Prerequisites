import XCTest
@testable import PaPre

class PaPreTests: XCTestCase {

  func testSwift() {
    let sw = MacOSInfo.Swift
    XCTAssertGreaterThan(sw.count, 0)
    XCTAssertNotNil(sw["Swift"])
    XCTAssertNotNil(sw["swiftlang"])
    XCTAssertNotNil(sw["clang"])
    XCTAssertNotNil(sw["Target"])
    print(sw["Swift"] ?? "Swift Version Fault")
    // will print 3.1
    print(sw["swiftlang"] ?? "swiftlang Version Fault")
    // will print 802.0.53
    print(sw["clang"] ?? "clang Version Fault")
    // will print 802.0.42
    print(sw["Target"] ?? "Target Version Fault")
    // will print x86_64-apple-macosx10.9
  }

  func testXcode() {
    let xcode = MacOSInfo.Xcode
    XCTAssertGreaterThan(xcode.count, 0)
    print(xcode)
    XCTAssertNotNil(xcode["CFBundleShortVersionString"])
    if let v = xcode["CFBundleShortVersionString"] as? String {
      print(v)
      // will print 8.3.3
    }
  }

  func testPing() {
    let ex = self.expectation(description: "ping")
    MacOSInfo.Ping(ip: "github.com", timeout: 3) { metrics in
      XCTAssertGreaterThan(metrics.count, 3)
      print(metrics["min"] ?? -1.0)
      print(metrics["avg"] ?? -1.0)
      print(metrics["max"] ?? -1.0)
      print(metrics["stddev"] ?? -1.0)
      ex.fulfill()
    }
    self.wait(for: [ex], timeout: 10)
  }

  func testHomebrew() {
    guard let brew = MacOSInfo.Homebrew else {
      XCTFail("Homebrew Not installed")
      return
    }
    print(brew)
  }
  static var allTests = [
    ("testSwift", testSwift),
    ("testXcode", testXcode),
    ("testPing", testPing),
    ("testHomebrew", testHomebrew)
    ]
}
