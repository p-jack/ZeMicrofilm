import Atomics
import Foundation

var files = Files()

final class Files {

  private var atomicFail = ManagedAtomic(false)
  var fail:Bool {
    get {
      atomicFail.load(ordering:.sequentiallyConsistent)
    }
    set {
      atomicFail.store(newValue, ordering:.sequentiallyConsistent)
    }
  }

  var docsURL:URL {
    FileManager.default.urls(for:.documentDirectory, in:.userDomainMask).first!
  }
  
  func doc(_ path:String) -> URL {
    docsURL.appendingPathComponent(path)
  }

  func docs() throws -> [String] {
    if fail { throw FakeFileError.fakeout }
    return try FileManager.default.contentsOfDirectory(atPath:docsURL.path)
  }
  
  func exists(_ url:URL) -> Bool {
    FileManager.default.fileExists(atPath:url.path)
  }

  func load(_ url:URL) throws -> Data {
    if fail { throw FakeFileError.fakeout }
    return try Data(contentsOf:url)
  }

  func save(_ data:Data, to url:URL) throws {
    if fail { throw FakeFileError.fakeout }
    try data.write(to:url)
  }

  func delete(_ url: URL) throws {
    if fail { throw FakeFileError.fakeout }
    try FileManager.default.removeItem(at:url)
  }

}

enum FakeFileError:Error {
  case fakeout
}
