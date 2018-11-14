//: To run this playground start a SimpleHTTPServer on the commandline like this:
//:
//: `python -m SimpleHTTPServer 8000`
//:
//: It will serve up the current directory, so make sure to be in the directory containing episodes.json

import UIKit
import XCPlayground


typealias JSONDictionary = [String: AnyObject]

let url = NSURL(string: "http://localhost:8000/episodes.json")!


struct Episode {
    let id: String
    let title: String
}

extension Episode {
    init?(dictionary: JSONDictionary) {
        guard let id = dictionary["id"] as? String,
            title = dictionary["title"] as? String else { return nil }
        self.id = id
        self.title = title
    }
}


struct Media {}


struct Resource<A> {
    let url: NSURL
    let parse: (NSData) -> A?
}

extension Resource {
    init(url: NSURL, parseJSON: (AnyObject)@escaping  -> A?) {
        self.url = url
        self.parse = { data in
            let json = try? JSONSerialization.jsonObject(with: data as Data, options: [])
            return json.flatMap(parseJSON as! (Any) throws -> _?)
        }
    }
}


extension Episode {
    static let all = Resource<[Episode]>(url: url, parse: { json in
        guard let dictionaries = json as? [JSONDictionary] else { return nil }
        return dictionaries.flatMap(Episode.init)
    })
}


final class Webservice {
    func load<A>(resource: Resource<A>, completion: (A?) -> ()) {
        URLSessionURLSession.sharedSession.dataTaskWithURL(resource.url) { data, _, _ in
            guard let data = data else {
                completion(nil)
                return
            }
            completion(resource.parse(data))
            }.resume()
    }
}


XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

Webservice().load(Episode.all) { result in
    print(result)
}

