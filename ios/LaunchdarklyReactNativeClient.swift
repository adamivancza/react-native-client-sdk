
import Foundation
import LaunchDarkly

@objc(LaunchdarklyReactNativeClient)
class LaunchdarklyReactNativeClient: RCTEventEmitter {
    private var listenerKeys: [String:LDObserverOwner] = [:]
    
    private let FLAG_PREFIX = "LaunchDarkly-Flag-"
    private let ALL_FLAGS_PREFIX = "LaunchDarkly-All-Flags-"
    private let CONNECTION_MODE_PREFIX = "LaunchDarkly-Connection-Mode-"
    private let ERROR_INIT = "E_INITIALIZE"
    private let ERROR_IDENTIFY = "E_IDENTIFY"
    
    override func supportedEvents() -> [String]! {
        return [FLAG_PREFIX, ALL_FLAGS_PREFIX, CONNECTION_MODE_PREFIX]
    }
    
    override func constantsToExport() -> [AnyHashable: Any] {
        return ["FLAG_PREFIX": FLAG_PREFIX, "ALL_FLAGS_PREFIX": ALL_FLAGS_PREFIX, "CONNECTION_MODE_PREFIX": CONNECTION_MODE_PREFIX]
    }
    
    override static func requiresMainQueueSetup() -> Bool {
        return false
    }
    
    @objc func configure(_ config: NSDictionary, userConfig: NSDictionary, resolve: @escaping RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) -> Void {

        let config = configBuild(config: config)
        let user = userBuild(userConfig: userConfig)

        if config != nil && user != nil {
            LDClient.shared.startCompleteWhenFlagsReceived(config: config!, user: user, completion: {() -> Void in
                resolve(nil)})
        }
    }
    
    private func configBuild(config: NSDictionary) -> LDConfig? {
        let mobileKey = config["mobileKey"]
        
        if mobileKey == nil || !(mobileKey is String) {
            return nil
        }
        
        let safeKey = mobileKey as! String
        var ldConfig = LDConfig(mobileKey: safeKey)
        
        if config["baseUri"] != nil  {
            ldConfig.baseUrl = URL.init(string: config["baseUri"] as! String)!
        }
        
        if config["eventsUri"] != nil  {
            ldConfig.eventsUrl = URL.init(string: config["eventsUri"] as! String)!
        }
        
        if config["streamUri"] != nil  {
            ldConfig.streamUrl = URL.init(string: config["streamUri"] as! String)!
        }
        
        if config["eventsCapacity"] != nil  {
            ldConfig.eventCapacity = config["eventsCapacity"] as! Int
        }
        
        if config["eventsFlushIntervalMillis"] != nil  {
            ldConfig.eventFlushInterval = TimeInterval(config["eventsFlushIntervalMillis"] as! Float / 1000)
        }
        
        if config["connectionTimeoutMillis"] != nil  {
            ldConfig.connectionTimeout = TimeInterval(config["connectionTimeoutMillis"] as! Float / 1000)
        }
        
        if config["pollingIntervalMillis"] != nil  {
            ldConfig.flagPollingInterval = TimeInterval(config["pollingIntervalMillis"] as! Float / 1000)
        }
        
        if config["backgroundPollingIntervalMillis"] != nil  {
            ldConfig.backgroundFlagPollingInterval = TimeInterval(config["backgroundPollingIntervalMillis"] as! Float / 1000)
        }
        
        if config["useReport"] != nil  {
            ldConfig.useReport = config["useReport"] as! Bool
        }
        
        if config["stream"] != nil  {
            ldConfig.streamingMode = (config["stream"] as! Bool) ? LDStreamingMode.streaming : LDStreamingMode.polling
        }
        
        if config["disableBackgroundUpdating"] != nil  {
            ldConfig.enableBackgroundUpdates = !(config["disableBackgroundUpdating"] as! Bool)
        }
        
        if config["offline"] != nil  {
            ldConfig.startOnline = !(config["offline"] as! Bool)
        }
        
        if config["debugMode"] != nil {
            ldConfig.isDebugMode = config["debugMode"] as! Bool
        }

        if config["evaluationReasons"] != nil {
            ldConfig.evaluationReasons = config["evaluationReasons"] as! Bool
        }
        
        return ldConfig
    }
    
    private func userBuild(userConfig: NSDictionary) -> LDUser? {
        var user = LDUser()
        user.key = userConfig["key"] as! String
        
        if userConfig["name"] != nil {
            user.name = userConfig["name"] as? String
        }
        
        if userConfig["firstName"] != nil {
            user.firstName = userConfig["firstName"] as? String
        }
        
        if userConfig["lastName"] != nil {
            user.lastName = userConfig["lastName"] as? String
        }
        
        if userConfig["email"] != nil {
            user.email = userConfig["email"] as? String
        }
        
        if userConfig["anonymous"] != nil {
            user.isAnonymous = userConfig["anonymous"] as! Bool
        }
        
        if userConfig["country"] != nil {
            user.country = userConfig["country"] as? String
        }
        
        if userConfig["privateAttributeNames"] != nil  {
            user.privateAttributes = userConfig["privateAttributeNames"] as? [String]
        }
        
        if let customAttributes = userConfig["custom"] as! [String: Any]? {
            user.custom = customAttributes
        }
        
        return user
    }
    
    @objc func boolVariationFallback(_ flagKey: String, fallback: ObjCBool, resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) -> Void {
        resolve(LDClient.shared.variation(forKey: flagKey, fallback: fallback.boolValue) as Bool)
    }
    
    @objc func intVariationFallback(_ flagKey: String, fallback: Int, resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) -> Void {
        resolve(LDClient.shared.variation(forKey: flagKey, fallback: fallback) as Int)
    }
    
    @objc func floatVariationFallback(_ flagKey: String, fallback: CGFloat, resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) -> Void {
        resolve(LDClient.shared.variation(forKey: flagKey, fallback: Double(fallback)) as Double)
    }
    
    @objc func stringVariationFallback(_ flagKey: String, fallback: String, resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) -> Void {
        resolve(LDClient.shared.variation(forKey: flagKey, fallback: fallback) as String)
    }
    
    @objc func boolVariation(_ flagKey: String, resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) -> Void {
        let boolFlagValue: Bool? = LDClient.shared.variation(forKey: flagKey)
        resolve(boolFlagValue)
    }
    
    @objc func intVariation(_ flagKey: String, resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) -> Void {
        let intFlagValue: Int? = LDClient.shared.variation(forKey: flagKey)
        resolve(intFlagValue)
    }
    
    @objc func floatVariation(_ flagKey: String, resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) -> Void {
        let floatFlagValue: Double? = LDClient.shared.variation(forKey: flagKey)
        resolve(floatFlagValue)
    }
    
    @objc func stringVariation(_ flagKey: String, resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) -> Void {
        let stringFlagValue: String? = LDClient.shared.variation(forKey: flagKey)
        resolve(stringFlagValue)
    }

    @objc func jsonVariationNone(_ flagKey: String, resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) -> Void {
        let jsonFlagValue: Dictionary<String, Any>? = LDClient.shared.variation(forKey: flagKey)
        resolve(jsonFlagValue)
    }

    @objc func jsonVariationNumber(_ flagKey: String, fallback: Double, resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) -> Void {
        resolve(LDClient.shared.variation(forKey: flagKey, fallback: fallback) as Double)
    }

    @objc func jsonVariationBool(_ flagKey: String, fallback: Bool, resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) -> Void {
        resolve(LDClient.shared.variation(forKey: flagKey, fallback: fallback) as Bool)
    }

    @objc func jsonVariationString(_ flagKey: String, fallback: String, resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) -> Void {
        resolve(LDClient.shared.variation(forKey: flagKey, fallback: fallback) as String)
    }

    @objc func jsonVariationArray(_ flagKey: String, fallback: Array<RCTConvert>, resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) -> Void {
        resolve(LDClient.shared.variation(forKey: flagKey, fallback: fallback) as Array)
    }

    @objc func jsonVariationObject(_ flagKey: String, fallback: NSDictionary, resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) -> Void {
        resolve(LDClient.shared.variation(forKey: flagKey, fallback: fallback.swiftDictionary) as NSDictionary)
    }
    
    @objc func boolVariationDetailFallback(_ flagKey: String, fallback: ObjCBool, resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) -> Void {
        let detail = LDClient.shared.variationDetail(forKey: flagKey, fallback: fallback.boolValue)
        let jsonObject: NSDictionary = [
            "value": detail.value,
            "variationIndex": detail.variationIndex,
            "reason": detail.reason
        ]
        resolve(jsonObject)
    }
    
    @objc func intVariationDetailFallback(_ flagKey: String, fallback: Int, resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) -> Void {
        let detail = LDClient.shared.variationDetail(forKey: flagKey, fallback: fallback)
        let jsonObject: NSDictionary = [
            "value": detail.value,
            "variationIndex": detail.variationIndex,
            "reason": detail.reason
        ]
        resolve(jsonObject)
    }
    
    @objc func floatVariationDetailFallback(_ flagKey: String, fallback: CGFloat, resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) -> Void {
        let detail = LDClient.shared.variationDetail(forKey: flagKey, fallback: Double(fallback))
        let jsonObject: NSDictionary = [
            "value": detail.value,
            "variationIndex": detail.variationIndex,
            "reason": detail.reason
        ]
        resolve(jsonObject)
    }
    
    @objc func stringVariationDetailFallback(_ flagKey: String, fallback: String, resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) -> Void {
        let detail = LDClient.shared.variationDetail(forKey: flagKey, fallback: fallback)
        let jsonObject: NSDictionary = [
            "value": detail.value,
            "variationIndex": detail.variationIndex,
            "reason": detail.reason
        ]
        resolve(jsonObject)
    }
    
    @objc func boolVariationDetail(_ flagKey: String, resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) -> Void {
        let detail: EvaluationDetail<Bool?> = LDClient.shared.variationDetail(forKey: flagKey)
        let jsonObject: NSDictionary = [
            "value": detail.value,
            "variationIndex": detail.variationIndex,
            "reason": detail.reason
        ]
        resolve(jsonObject)
    }
    
    @objc func intVariationDetail(_ flagKey: String, resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) -> Void {
        let detail: EvaluationDetail<Int?> = LDClient.shared.variationDetail(forKey: flagKey)
        let jsonObject: NSDictionary = [
            "value": detail.value,
            "variationIndex": detail.variationIndex,
            "reason": detail.reason
        ]
        resolve(jsonObject)
    }
    
    @objc func floatVariationDetail(_ flagKey: String, resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) -> Void {
        let detail: EvaluationDetail<Double?> = LDClient.shared.variationDetail(forKey: flagKey)
        let jsonObject: NSDictionary = [
            "value": detail.value,
            "variationIndex": detail.variationIndex,
            "reason": detail.reason
        ]
        resolve(jsonObject)
    }
    
    @objc func stringVariationDetail(_ flagKey: String, resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) -> Void {
        let detail: EvaluationDetail<String?> = LDClient.shared.variationDetail(forKey: flagKey)
        let jsonObject: NSDictionary = [
            "value": detail.value,
            "variationIndex": detail.variationIndex,
            "reason": detail.reason
        ]
        resolve(jsonObject)
    }
    
    @objc func jsonVariationDetailNone(_ flagKey: String, resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) -> Void {
        let detail: EvaluationDetail<Dictionary<String, Any>?> = LDClient.shared.variationDetail(forKey: flagKey)
        let jsonObject: NSDictionary = [
            "value": detail.value,
            "variationIndex": detail.variationIndex,
            "reason": detail.reason
        ]
        resolve(jsonObject)
    }
    
    @objc func jsonVariationDetailNumber(_ flagKey: String, fallback: Double, resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) -> Void {
        let detail = LDClient.shared.variationDetail(forKey: flagKey, fallback: fallback)
        let jsonObject: NSDictionary = [
            "value": detail.value,
            "variationIndex": detail.variationIndex,
            "reason": detail.reason
        ]
        resolve(jsonObject)
    }
    
    @objc func jsonVariationDetailBool(_ flagKey: String, fallback: Bool, resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) -> Void {
        let detail = LDClient.shared.variationDetail(forKey: flagKey, fallback: fallback)
        let jsonObject: NSDictionary = [
            "value": detail.value,
            "variationIndex": detail.variationIndex,
            "reason": detail.reason
        ]
        resolve(jsonObject)
    }
    
    @objc func jsonVariationDetailString(_ flagKey: String, fallback: String, resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) -> Void {
        let detail = LDClient.shared.variationDetail(forKey: flagKey, fallback: fallback)
        let jsonObject: NSDictionary = [
            "value": detail.value,
            "variationIndex": detail.variationIndex,
            "reason": detail.reason
        ]
        resolve(jsonObject)
    }
    
    @objc func jsonVariationDetailArray(_ flagKey: String, fallback: Array<RCTConvert>, resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) -> Void {
        let detail = LDClient.shared.variationDetail(forKey: flagKey, fallback: fallback)
        let jsonObject: NSDictionary = [
            "value": detail.value,
            "variationIndex": detail.variationIndex,
            "reason": detail.reason
        ]
        resolve(jsonObject)
    }
    
    @objc func jsonVariationDetailObject(_ flagKey: String, fallback: NSDictionary, resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) -> Void {
        let detail = LDClient.shared.variationDetail(forKey: flagKey, fallback: fallback.swiftDictionary)
        let jsonObject: NSDictionary = [
            "value": detail.value,
            "variationIndex": detail.variationIndex,
            "reason": detail.reason
        ]
        resolve(jsonObject)
    }

    @objc func trackNumber(_ eventName: String, data: NSNumber) -> Void {
        try? LDClient.shared.trackEvent(key: eventName, data: data)
    }

    @objc func trackBool(_ eventName: String, data: ObjCBool) -> Void {
        try? LDClient.shared.trackEvent(key: eventName, data: data.boolValue)
    }

    @objc func trackString(_ eventName: String, data: String) -> Void {
        try? LDClient.shared.trackEvent(key: eventName, data: data)
    }

    @objc func trackArray(_ eventName: String, data: NSArray) -> Void {
        try? LDClient.shared.trackEvent(key: eventName, data: data)
    }

    @objc func trackObject(_ eventName: String, data: NSDictionary) -> Void {
        try? LDClient.shared.trackEvent(key: eventName, data: data.swiftDictionary)
    }

    @objc func track(_ eventName: String) -> Void {
        try? LDClient.shared.trackEvent(key: eventName)
    }
    
    @objc func trackNumberMetricValue(_ eventName: String, data: NSNumber, metricValue: Double) -> Void {
        try? LDClient.shared.trackEvent(key: eventName, data: data, metricValue: metricValue)
    }
    
    @objc func trackBoolMetricValue(_ eventName: String, data: ObjCBool, metricValue: Double) -> Void {
        try? LDClient.shared.trackEvent(key: eventName, data: data.boolValue, metricValue: metricValue)
    }
    
    @objc func trackStringMetricValue(_ eventName: String, data: String, metricValue: Double) -> Void {
        try? LDClient.shared.trackEvent(key: eventName, data: data, metricValue: metricValue)
    }
    
    @objc func trackArrayMetricValue(_ eventName: String, data: NSArray, metricValue: Double) -> Void {
        try? LDClient.shared.trackEvent(key: eventName, data: data, metricValue: metricValue)
    }
    
    @objc func trackObjectMetricValue(_ eventName: String, data: NSDictionary, metricValue: Double) -> Void {
        try? LDClient.shared.trackEvent(key: eventName, data: data.swiftDictionary, metricValue: metricValue)
    }
    
    @objc func trackMetricValue(_ eventName: String, metricValue: Double) -> Void {
        try? LDClient.shared.trackEvent(key: eventName, metricValue: metricValue)
    }

    @objc func setOffline(_ resolve: @escaping RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) -> Void {
        LDClient.shared.setOnline(false) {
            return resolve(true)
        }
    }
    
    @objc func isOffline(_ resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) -> Void {
        resolve(!LDClient.shared.isOnline)
    }
    
    @objc func setOnline(_ resolve: @escaping RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) -> Void {
        LDClient.shared.setOnline(true) {
            return resolve(true)
        }
    }
    
    @objc func flush() -> Void {
        LDClient.shared.reportEvents()
    }
    
    @objc func close(_ resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) -> Void {
        LDClient.shared.stop()
        resolve(true)
    }
    
    @objc func identify(_ options: NSDictionary, resolve: @escaping RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) -> Void {
        let user = userBuild(userConfig: options)
        if let usr = user {
            LDClient.shared.identify(user: usr) {
                resolve(nil)
            }
        } else {
            reject(ERROR_IDENTIFY, "User could not be built using supplied configuration", nil)
        }
    }
    
    @objc func allFlags(_ resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) -> Void {
        var allFlagsDict: [String: Any] = [:]
        if let allFlags = LDClient.shared.allFlagValues {
            for (key, value) in allFlags {
                allFlagsDict[key] = value
            }
        }
        resolve(allFlagsDict as NSDictionary)
    }
    
    @objc func registerFeatureFlagListener(_ flagKey: String) -> Void {
        let flagChangeOwner = flagKey as LDObserverOwner
        if listenerKeys[flagKey] == nil {
            listenerKeys[flagKey] = flagChangeOwner
        } else {
            return
        }
        LDClient.shared.observe(keys: [flagKey], owner: flagChangeOwner, handler: { (changedFlags) in
            if changedFlags[flagKey] != nil && self.bridge != nil {
                self.sendEvent(withName: self.FLAG_PREFIX, body: ["flagKey": flagKey])
            }
        })
    }
    
    private func unregisterListener(_ key: String) -> Void {
        let owner = key as LDObserverOwner
        if listenerKeys[key] != nil {
            listenerKeys.removeValue(forKey: key)
        } else {
            return
        }
        LDClient.shared.stopObserving(owner: owner)
    }
    
    @objc func unregisterFeatureFlagListener(_ flagKey: String) -> Void {
        unregisterListener(flagKey)
    }
    
    @objc func isDisableBackgroundPolling(_ resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) -> Void {
        resolve(LDClient.shared.config.enableBackgroundUpdates)
    }
    
    @objc func getConnectionInformation(_ resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) -> Void {
        resolve(LDClient.shared.getConnectionInformation())
    }
    
    @objc func registerCurrentConnectionModeListener(_ listenerId: String) -> Void {
        let currentConnectionModeOwner = listenerId as LDObserverOwner
        if listenerKeys[listenerId] == nil {
            listenerKeys.removeValue(forKey: listenerId)
        } else {
            return
        }
        LDClient.shared.observeCurrentConnectionMode(owner: currentConnectionModeOwner, handler: { (connectionMode) in
            if self.bridge != nil {
                self.sendEvent(withName: self.CONNECTION_MODE_PREFIX, body: ["connectionMode": connectionMode])
            }
        })
    }
    
    @objc func unregisterCurrentConnectionModeListener(_ listenerId: String) -> Void {
        unregisterListener(listenerId)
    }
    
    @objc func registerAllFlagsListener(_ listenerId: String) -> Void {
        let flagChangeOwner = listenerId as LDObserverOwner
        if listenerKeys[listenerId] == nil {
            listenerKeys[listenerId] = flagChangeOwner
        } else {
            return
        }
        LDClient.shared.observeAll(owner: flagChangeOwner, handler: { (changedFlags) in
            if self.bridge != nil {
                self.sendEvent(withName: self.ALL_FLAGS_PREFIX, body: ["flagKeys": changedFlags.description])
            }
        })
    }
    
    @objc func unregisterAllFlagsListener(_ listenerId: String) -> Void {
        unregisterListener(listenerId)
    }
}

extension NSDictionary {
    @objc var swiftDictionary: Dictionary<String, Any> {
        var swiftDictionary = Dictionary<String, Any>()
        
        for key : Any in self.allKeys {
            let stringKey = key as! String
            if let keyValue = self.value(forKey: stringKey) {
                swiftDictionary[stringKey] = keyValue
            }
        }
        
        return swiftDictionary;
    }
}
