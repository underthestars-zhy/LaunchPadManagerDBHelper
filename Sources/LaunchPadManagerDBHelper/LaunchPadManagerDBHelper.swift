import SQLite
import Foundation
import SwiftUI

public struct LaunchPadManagerDBHelper {
    let db: Connection
    let appsTable = Table("apps")

    public init(_ path: URL) throws {
        try self.db = Connection(path.universalPath())
    }

    public func getAllAppInfos() throws -> [AppInfo] {
        let apps = try db.prepare(appsTable).map { row in
            Apps(id: row[Expression<Int>("item_id")], title: row[Expression<String>("title")], bookmark: row[Expression<Data>("bookmark")])
        }

        return try apps.compactMap { app in
            var isStale = false
            let url = try URL(resolvingBookmarkData: app.bookmark, bookmarkDataIsStale: &isStale)
            return .init(url: url, name: app.title)
        }
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
