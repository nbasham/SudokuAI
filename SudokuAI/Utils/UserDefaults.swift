import Foundation

public extension UserDefaults {

    static func get<T: Codable>(forKey key: String, defaultValue: T) -> T {
        let a: T? = UserDefaults.get(forKey: key)
        return a ?? defaultValue
    }
    static func get<T: Codable>(forKey key: String) -> T? {
        let s = UserDefaults.standard.object(forKey: key) as? String
        let a: T? = s?.data(using: .utf8)?.decode()
        return a
    }
    static func set(_ o: Codable, forKey key: String) {
        if let s = o.encode()?.asString {
            UserDefaults.standard.set(s, forKey: key)
        }
    }
    static func setOnce(_ value: Any, forKey key: String) {
        guard UserDefaults.standard.object(forKey: key) == nil else { return }
        UserDefaults.standard.set(value, forKey: key)
    }
}

//  old school
public extension UserDefaults {

    static func isUndefined(key: String) -> Bool {
        return UserDefaults.standard.object(forKey: key) == nil
    }

    static func exists(key: String) -> Bool {
        return UserDefaults.standard.object(forKey: key) != nil
    }

    static func isUndefinedThenDefine(key: String) -> Bool {
        let b = isUndefined(key: key)
        if b {
            UserDefaults.standard.set(Date(), forKey: key)
            UserDefaults.standard.synchronize()
        }
        return b
    }

    static func getb(_ key: String) -> Bool {
        return UserDefaults.standard.bool(forKey: key)
    }

    static func geti(_ key: String) -> Int {
        return UserDefaults.standard.integer(forKey: key)
    }

    static func getui(_ key: String) -> UInt {
        return UInt(UserDefaults.geti(key))
    }

    static func geto(_ key: String) -> Any? {
        return UserDefaults.standard.object(forKey: key)
    }

    static func remove(_ key: String) {
        UserDefaults.standard.removeObject(forKey: key)
        UserDefaults.standard.synchronize()
    }

    static func save(_ value: Any, forKey key: String) {
        UserDefaults.standard.set(value, forKey: key)
        UserDefaults.standard.synchronize()
    }

}

public extension Data {

    var asString: String { return String(decoding: self, as: UTF8.self) }

    func decode<T: Codable>() -> T? {
        do {
            let decoder = JSONDecoder()
            if #available(iOS 10.0, *) {
                decoder.dateDecodingStrategy = .iso8601
            }
            let resource = try decoder.decode(T.self, from: self)
            return resource

        //  Printing error.localizedDescription in Decodable catch blocks is misleading because it displays only a quite meaningless generic error message.
        } catch let DecodingError.dataCorrupted(context) {
            print(context)
        } catch let DecodingError.keyNotFound(key, context) {
            print("Key '\(key)' not found:", context.debugDescription)
            print("codingPath:", context.codingPath)
        } catch let DecodingError.valueNotFound(value, context) {
            print("Value '\(value)' not found:", context.debugDescription)
            print("codingPath:", context.codingPath)
        } catch let DecodingError.typeMismatch(type, context)  {
            print("Type '\(type)' mismatch:", context.debugDescription)
            print("codingPath:", context.codingPath)
        } catch {
            print("error: ", error)
        }
        return nil
    }
}

public extension Encodable {

    var jsonString: String? {
        return encode(isPretty: true)?.asString
    }
    func encode(isPretty: Bool = false) -> Data? {
        do {
            let encoder = JSONEncoder()
            if #available(iOS 10.0, *) {
                encoder.dateEncodingStrategy = .iso8601
            }
            if isPretty {
                encoder.outputFormatting = .prettyPrinted
            }
            let data = try encoder.encode(self)
            return data
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
}
