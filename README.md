# MacOS Info Checker

This library provides runtime info of Xcode / Swift / Homebrew installations.


``` swift
import PaPre

if let brew = MacOSInfo.Homebrew {
	print(brew)
	// will be 1.3.0 
}

let sw = MacOSInfo.Swift
print(sw["Swift"] ?? "Swift Version Fault")
// will print 3.1
print(sw["swiftlang"] ?? "swiftlang Version Fault")
// will print 802.0.53
print(sw["clang"] ?? "clang Version Fault")
// will print 802.0.42
print(sw["Target"] ?? "Target Version Fault")
// will print x86_64-apple-macosx10.9

let xcode = MacOSInfo.Xcode

if let v = xcode["CFBundleShortVersionString"] as? String {
  print(v)
  // will print 8.3.3
}

MacOSInfo.Ping(ip: "github.com", timeout: 3) { metrics in
  // ideally min/avg/max should be less than 20.0 ms
  // stddev should be less than 3 ms
  print(metrics["min"] ?? -1.0)
  print(metrics["avg"] ?? -1.0)
  print(metrics["max"] ?? -1.0)
  print(metrics["stddev"] ?? -1.0)
}

let docker = DockerCloud()
docker.speedTest { latency in
  // normally latency is around 300 ms
  print("docker cloud latency", latency)
}

if let v = MacOSInfo.DockerVersion {
	print(v)
	// v looks like '17.07.0-ce-rc2, build 36ce605'
}

if MacOSInfo.DockerApp {
	print("Docker is running")
}
```
