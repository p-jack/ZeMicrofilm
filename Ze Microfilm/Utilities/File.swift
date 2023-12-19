import Foundation

func docsURL() -> URL {
  return FileManager.default.urls(for:.documentDirectory, in:.userDomainMask).first!
}

func doc(_ path:String) -> URL {
  return docsURL().appendingPathComponent(path)
}

func docs() throws -> [String] {
  return try FileManager.default.contentsOfDirectory(atPath:docsURL().path)
}
