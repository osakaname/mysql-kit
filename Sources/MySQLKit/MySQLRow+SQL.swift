@preconcurrency import MySQLNIO
import SQLKit

extension MySQLRow {
    public func sql(decoder: MySQLDataDecoder = .init()) -> SQLRow {
        _MySQLSQLRow(row: self, decoder: decoder)
    }
}

struct MissingColumn: Error {
    let column: String
}

public struct _MySQLSQLRow: SQLRow {
    public let row: MySQLRow
    let decoder: MySQLDataDecoder

    public var allColumns: [String] {
        self.row.columnDefinitions.map { $0.name }
    }

    public func contains(column: String) -> Bool {
        self.row.columnDefinitions.contains { $0.name == column }
    }

    public func decodeNil(column: String) throws -> Bool {
        guard let data = self.row.column(column) else {
            return true
        }
        return data.buffer == nil
    }

    public func decode<D>(column: String, as type: D.Type) throws -> D where D : Decodable {
        guard let data = self.row.column(column) else {
            throw MissingColumn(column: column)
        }
        return try self.decoder.decode(D.self, from: data)
    }
}
