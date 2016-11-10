//
//  TestHierarchy.swift
//  XcodeServerSDK
//
//  Created by Honza Dvorsky on 15/07/2015.
//  Copyright © 2015 Honza Dvorsky. All rights reserved.
//

import Foundation

let TestResultAggregateKey = "_xcsAggrDeviceStatus"

open class TestHierarchy : XcodeServerEntity {
    
    typealias TestResult = [String: Double]
    typealias AggregateResult = TestResult
    
    enum TestMethod {
        case method(TestResult)
        case aggregate(AggregateResult)
    }
    
    enum TestClass {
        case clazz([String: TestMethod])
        case aggregate(AggregateResult)
    }
    
    typealias TestTarget = [String: TestClass]
    typealias TestData = [String: TestTarget]
    
    let testData: TestData
    
    /*
    the json looks like this:
    {
        //target
        "XcodeServerSDKTest": {
            
            //class
            "BotParsingTests": {
                
                //method
                "testParseOSXBot()": {
    
                    //device -> number (bool)
                    "12345-67890": 1,
                    "09876-54321": 0
                },
                "testShared()": {
                    "12345-67890": 1,
                    "09876-54321": 1
                }
                "_xcsAggrDeviceStatus": {
                    "12345-67890": 1,
                    "09876-54321": 0
                }
            },
            "_xcsAggrDeviceStatus": {
                "12345-67890": 1,
                "09876-54321": 0
            }
        }
    }
    
    As a class and a method, there's always another key-value pair, with key "_xcsAggrDeviceStatus",
    which is the aggregated status, so that you don't have to iterate through all tests to figure it out yourself. 1 if all are 1, 0 otherwise.
    */
    
    public required init(json: NSDictionary) throws {
        
        //TODO: come up with useful things to parse
        //TODO: add search capabilities, aggregate generation etc

        self.testData = TestHierarchy.pullData(json)
        
        try super.init(json: json)
    }
    
    class func pullData(_ json: NSDictionary) -> TestData {
        
        var data = TestData()
        
        for (_targetName, _targetData) in json {
            let targetName = _targetName as! String
            let targetData = _targetData as! NSDictionary
            data[targetName] = pullTarget(targetName, targetData: targetData)
        }
        
        return data
    }
    
    class func pullTarget(_ targetName: String, targetData: NSDictionary) -> TestTarget {
        
        var target = TestTarget()
        
        for (_className, _classData) in targetData {
            let className = _className as! String
            let classData = _classData as! NSDictionary
            target[className] = pullClass(className, classData: classData)
        }
        
        return target
    }
    
    class func pullClass(_ className: String, classData: NSDictionary) -> TestClass {
        
        let classy: TestClass
        if className == TestResultAggregateKey {
            classy = TestClass.aggregate(classData as! AggregateResult)
        } else {
            
            var newData = [String: TestMethod]()
            
            for (_methodName, _methodData) in classData {
                let methodName = _methodName as! String
                let methodData = _methodData as! NSDictionary
                newData[methodName] = pullMethod(methodName, methodData: methodData)
            }
            
            classy = TestClass.clazz(newData)
        }
        return classy
    }
    
    class func pullMethod(_ methodName: String, methodData: NSDictionary) -> TestMethod {
        
        let method: TestMethod
        if methodName == TestResultAggregateKey {
            method = TestMethod.aggregate(methodData as! AggregateResult)
        } else {
            method = TestMethod.method(methodData as! TestResult)
        }
        return method
    }
}
