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

    public func getAllAppInfos() throws -> [AppInfo] {
        let apps = try db.prepare(appsTable).map { row in
            Apps(id: row[Expression<Int>("item_id")], title: row[Expression<String>("title")], bookmark: row[Expression<Data>("bookmark")])
        }

        return try apps.compactMap { app in
            var isStale = false
            let url = try URL(resolvingBookmarkData: app.bookmark, bookmarkDataIsStale: &isStale)
            return .init(id: app.id, url: url, name: app.title)
        }
    }

    public func removeApp(_ app: AppInfo) throws {
        try db.run(appsTable.where(Expression<Int>("item_id") == app.id).delete())
        try Self.safeShell("killall Dock")
    }

    struct Apps {
        let id: Int
        let title: String
        let bookmark: Data
    }

    public struct AppInfo {
        let id: Int
        public let url: URL
        public let name: String
    }
}
