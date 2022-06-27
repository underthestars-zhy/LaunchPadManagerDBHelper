import SQLite
import Foundation
import SwiftUI

public struct LaunchPadManagerDBHelper {
    let db: Connection
    let appsTable = Table("apps")

    public init() throws {
        let path = try Self.safeShell("echo /private$(getconf DARWIN_USER_DIR)com.apple.dock.launchpad/db/db").trimmingCharacters(in: .newlines)
        try self.db = Connection(path)
    }

    static func safeShell(_ command: String) throws -> String {
        let task = Process()
        let pipe = Pipe()

        task.standardOutput = pipe
        task.standardError = pipe
        task.arguments = ["-c", command]
        task.executableURL = URL(fileURLWithPath: "/bin/zsh")
        task.standardInput = nil

        try task.run()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)!

        return output
    }

    func getAllAppInfosFromApplication() throws -> [AppInfo] {
        let content = try FileManager.default.contentsOfDirectory(atPath: "/Applications")
        return content.filter{
            ($0 as NSString).pathExtension == "app"
        }.map { url in
            let url = URL(universalFilePath: "/Applications/\(url)")
            return AppInfo(url: url, name: url.deletingPathExtension().lastPathComponent)
        }
    }

    public func getAllAppInfos() throws -> [AppInfo] {
        let apps = try db.prepare(appsTable).map { row in
            Apps(id: row[Expression<Int>("item_id")], title: row[Expression<String>("title")], bookmark: row[Expression<Data>("bookmark")])
        }

        var infos: [AppInfo] = try apps.compactMap { app in
            var isStale = false
            let url = try URL(resolvingBookmarkData: app.bookmark, bookmarkDataIsStale: &isStale)
            return .init(url: url, name: app.title)
        }

        for app in try getAllAppInfosFromApplication() {
            if !infos.contains(where: { info in
                info.url.universalPath() == app.url.universalPath() + "/" || info.name == app.name
            }) {
                infos.append(app)
            }
        }

        return infos
    }

    struct Apps {
        let id: Int
        let title: String
        let bookmark: Data
    }

    public struct AppInfo {
        public let url: URL
        public let name: String
    }
}
