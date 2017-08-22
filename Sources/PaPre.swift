import Foundation

public extension Data {
  public var string : String? {
    return self.withUnsafeBytes { (pointer: UnsafePointer<CChar>) -> String? in
      guard self.count > 0 else { return nil }
      return String(cString: pointer)
    }
  }
}

public class DockerCloud {
  var then = DispatchTime.now()
  public init() { }
  public func speedTest(_ completion: @escaping (Int) -> Void) {
    guard let url = URL(string: "https://cloud.docker.com") else {
      completion(-1)
      return
    }

    self.then = DispatchTime.now()
    let task = URLSession.shared.dataTask(with: url) { _, _, err in
      if let _ = err {
        completion(-1)
      } else {
        let now = DispatchTime.now()
        let d = Double(now.uptimeNanoseconds - self.then.uptimeNanoseconds) / 1e6
        completion(Int(d))
      }
    }
    task.resume()
  }
}

public class MacOSInfo {

  public static var DockerVersion: String? {
    let task = Process()
    task.launchPath = "/bin/bash"
    task.arguments = ["-c", "/usr/local/bin/docker -v"]
    let oup = Pipe()
    task.standardOutput = oup
    task.launch()
    task.waitUntilExit()
    if let o = oup.fileHandleForReading.readDataToEndOfFile().string {
      var y = o
      y.append(Character("\0"))
      let x = y.replacingOccurrences(of: "Docker version ", with: "")
      return x
    }
    return nil
  }

  public static var DockerApp: Bool {
    let task = Process()
    task.launchPath = "/bin/bash"
    task.arguments = ["-c", "/usr/local/bin/docker ps"]
    let oup = Pipe()
    task.standardOutput = oup
    task.launch()
    task.waitUntilExit()
    if let o = oup.fileHandleForReading.readDataToEndOfFile().string,
      !o.contains("Error") {
      return true
    }
    return false
  }

  public static var Homebrew: String? {
    let task = Process()
    task.launchPath = "/bin/bash"
    task.arguments = ["-c", "/usr/local/bin/brew --version"]
    let oup = Pipe()
    task.standardOutput = oup
    task.launch()
    task.waitUntilExit()
    if let o = oup.fileHandleForReading.readDataToEndOfFile().string {
      let x = o.replacingOccurrences(of: "Homebrew ", with: "")
      let y = x.characters.split(separator: "\n").map { String($0) }
      if y.count > 1 {
        return y[0]
      }
    }
    return nil
  }

  public static var Swift: [String:String] {
    let task = Process()
    task.launchPath = "/bin/bash"
    task.arguments = ["-c", "swift --version"]
    let oup = Pipe()
    task.standardOutput = oup
    task.launch()
    task.waitUntilExit()
    var dic: [String: String] = [:]
    if let o = oup.fileHandleForReading.readDataToEndOfFile().string {
      let x = o.replacingOccurrences(of: "Apple Swift version ", with: "")
        .replacingOccurrences(of: " (swiftlang-", with: " ")
        .replacingOccurrences(of: " clang-", with: " ")
        .replacingOccurrences(of: ")\nTarget: ", with: " ")
      let y = x.characters.split(separator: " ").map { String($0) }
      if y.count > 3 {
        dic["Swift"] = y[0]
        dic["swiftlang"] = y[1]
        dic["clang"] = y[2]
        dic["Target"] = y[3]
      } else {
        dic["Error"] = "Parse Fault: \(o)"
      }
    } else {
      dic["Error"] = "Unknown"
    }
    return dic
  }

  public static var Xcode: [String: Any] {
    let url = URL(fileURLWithPath: "/Applications/Xcode.app/Contents/version.plist")
    if let data = try? Data(contentsOf: url),
      let properties = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil),
    let dic = properties as? [String: Any] {
      return dic
    } else {
      return [:]
    }
  }

  public static func Ping(ip: String, timeout: Int = 5, completion: @escaping ([String:Float]) -> Void ) {
    DispatchQueue(label: "ping.\(ip)").async {
      let task = Process()
      task.launchPath = "/bin/bash"
      task.arguments = ["-c", "ping \(ip)"]
      let oup = Pipe()
      let erp = Pipe()
      task.standardOutput = oup
      task.standardError = erp
      task.launch()
      DispatchQueue(label: "pong.\(ip)")
        .asyncAfter(deadline: DispatchTime.now() + Double(timeout)) {
          task.interrupt()
      }
      task.waitUntilExit()
      var o = oup.fileHandleForReading.readDataToEndOfFile().map { $0 }
      o.append(0)
      let feature = "round-trip min/avg/max/stddev = "
      var str = o.withUnsafeBufferPointer { buffer -> String in
        if let pointer = (buffer.baseAddress?.withMemoryRebound(to: Int8.self, capacity: o.count) {
          base -> UnsafePointer<CChar> in return base
          }),
          let beginning = strstr(pointer, feature) {
          return String(cString: beginning.advanced(by: feature.utf8.count))
        } else {
          return ""
        }
      }
      var res: [String: Float] = [:]
      if str.isEmpty {
        completion(res)
      }
      str = str.replacingOccurrences(of: " ms", with: "/")
      let metrics = str.characters.split(separator: "/").map { String($0) }
        .map { Float($0) }
      if metrics.count > 3 {
        res["min"] = metrics[0]
        res["avg"] = metrics[1]
        res["max"] = metrics[2]
        res["stddev"] = metrics[3]
      }
      completion(res)
    }
  }
}
