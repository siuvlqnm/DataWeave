import SwiftUI
import SwiftData

@Model
class DataTable {
    var id: UUID
    var name: String
    var tableDescription: String?
    var fields: [DataField]
    var createdAt: Date
    var updatedAt: Date
    var records: [DataRecord] // 反向关联

    init(name: String, description: String? = nil) {
        self.id = UUID()
        self.name = name
        self.tableDescription = description
        self.fields = []
        self.records = [] // 初始化为空数组
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

@Model
class DataField {
    @Attribute(.unique) var id: UUID
    var name: String
    var type: FieldType
    var isRequired: Bool
    var defaultValue: String?

    init(name: String, type: FieldType, isRequired: Bool = false, defaultValue: String? = nil) {
        self.id = UUID()
        self.name = name
        self.type = type
        self.isRequired = isRequired
        self.defaultValue = defaultValue
    }

    enum FieldType: String, Codable, CaseIterable {
        // 基础类型
        case text = "文本"
        case richText = "富文本"
        case number = "数字"
        case decimal = "小数"
        case boolean = "布尔"
        case date = "日期"
        case time = "时间"
        case dateTime = "日期时间"
        // 媒体类型
        case image = "图片"
        case file = "文件"
        // 选择类型
        case select = "单选"
        case multiSelect = "多选"
        // 联系信息
        case email = "邮箱"
        case phone = "电话"
        case url = "链接"
        case location = "位置"
        // 特殊类型
        case color = "颜色"
        case barcode = "条形码"
        case qrCode = "二维码"

        var icon: String {
            switch self {
            case .text: return "text.alignleft"
            case .richText: return "text.quote"
            case .number, .decimal: return "number"
            case .boolean: return "checkmark.square"
            case .date: return "calendar"
            case .time: return "clock"
            case .dateTime: return "calendar.badge.clock"
            case .image: return "photo"
            case .file: return "doc"
            case .select: return "list.bullet"
            case .multiSelect: return "list.bullet.indent"
            case .email: return "envelope"
            case .phone: return "phone"
            case .url: return "link"
            case .location: return "location"
            case .color: return "paintpalette"
            case .barcode: return "barcode"
            case .qrCode: return "qrcode"
            }
        }

        var isPro: Bool {
            switch self {
            case .text, .richText, .number, .decimal,
                 .boolean, .date, .time, .dateTime,
                 .image, .file, .select, .multiSelect,
                 .email, .phone, .url:
                return false
            default:
                return true
            }
        }
    }
}