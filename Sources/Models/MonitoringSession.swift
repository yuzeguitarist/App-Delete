import Foundation

struct MonitoringSession: Identifiable, Codable, Hashable {
    let id: UUID
    let name: String
    let startDate: Date
    var endDate: Date?
    var isActive: Bool
    var monitoredFiles: [MonitoredFile]
    
    var formattedStartDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: startDate)
    }
    
    var formattedEndDate: String? {
        guard let endDate = endDate else { return nil }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: endDate)
    }
    
    var totalSize: Int64 {
        monitoredFiles.reduce(0) { $0 + $1.size }
    }
    
    var formattedSize: String {
        ByteCountFormatter.string(fromByteCount: totalSize, countStyle: .file)
    }
    
    init(id: UUID = UUID(), name: String, startDate: Date = Date(), endDate: Date? = nil, isActive: Bool = true, monitoredFiles: [MonitoredFile] = []) {
        self.id = id
        self.name = name
        self.startDate = startDate
        self.endDate = endDate
        self.isActive = isActive
        self.monitoredFiles = monitoredFiles
    }
}

struct MonitoredFile: Identifiable, Codable, Hashable {
    let id: UUID
    let path: String
    let size: Int64
    let createdAt: Date
    let type: FileType
    
    enum FileType: String, Codable {
        case application
        case support
        case cache
        case preference
        case log
        case config
        case temporary
        case other
    }
    
    init(id: UUID = UUID(), path: String, size: Int64, createdAt: Date = Date(), type: FileType) {
        self.id = id
        self.path = path
        self.size = size
        self.createdAt = createdAt
        self.type = type
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: MonitoredFile, rhs: MonitoredFile) -> Bool {
        lhs.id == rhs.id
    }
}
