//: Playground - noun: a place where people can play

import UIKit

//let url = NSURL(string: "http://jsonplaceholder.typicode.com/posts")!
let url = NSURL(string: "http://google.com")!
let data = NSData(contentsOfURL: url)!

func parseData(data: NSData) throws -> AnyObject? {
    do {
        let parsed = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
        return parsed
    } catch {
        print(error as NSError)
        return nil
    }
}

let obj = try parseData(data)
