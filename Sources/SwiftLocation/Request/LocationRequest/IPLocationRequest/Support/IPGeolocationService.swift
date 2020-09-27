//
//  File.swift
//  
//
//  Created by daniele on 27/09/2020.
//

import Foundation

/// This is the implementation of IPGeolocation location search by ip.
/// https://ipgeolocation.io
public class IPGeolocationService: IPService {
    
    /// Used to retrive data from json.
    public var jsonServiceDecoder: IPServiceDecoders = .ipgeolocation

    // MARK: - Configurable Settings
    
    /// Optional target IP to discover; `nil` to use current machine internet address.
    public let targetIPs: [String]?
    
    /// API key. See https://app.ipgeolocation.io.
    public let APIKey: String?
    
    
    /// Locale identifier.
    /// Not all languages are supported (https://ip-api.com/docs/api:json).
    public var locale = Locale(identifier: "en")
    
    /// Hostname lookup.
    /// By default, the ipstack API does not return information about the hostname the given IP address resolves to.
    public var hostnameLookup = false
    
    // MARK: - Protocol Specific
    
    /// Service underlying.
    public var task: URLSessionDataTask?
    
    /// Operation was cancelled.
    public var isCancelled = false
    
    /// Timeout interval to execute the call.
    public var timeout: TimeInterval = 5
    
    /// Session URL session.
    public var session = URLSession.shared
    
    /// Initialize a new https://ip-api.com service with given parameters.
    ///
    /// - Parameters:
    ///   - targetIP: IP to discover; ignore this parameter to get the location of the currently machine.
    ///   - APIKey: API Key for service. Signup at https://app.ipgeolocation.io.
    public init(targetIPs: [String]? = nil, APIKey: String) {
        self.targetIPs = targetIPs
        self.APIKey = APIKey
    }
    
    public func buildRequest() throws -> URLRequest {
        let serviceURL = URL(string: "https://api.ipgeolocation.io/ipgeo")!
        var urlComponents = URLComponents(string: serviceURL.absoluteString)
        
        var httpMethod = "GET"
        var httpBody: Data? = nil
        var queryItems = [
            URLQueryItem(name: "apiKey", value: APIKey),
            URLQueryItem(name: "lang", value: locale.collatorIdentifier?.lowercased())
        ]
        
        if let targetIPs = targetIPs {
            if targetIPs.count == 1 { // single ip lookup
                queryItems.append(URLQueryItem(name: "ip", value: targetIPs.first!))
            } else { // multiple ips lookup
                httpMethod = "POST"
                httpBody = try? JSONSerialization.data(withJSONObject: ["ips": targetIPs], options: .prettyPrinted)
            }
        } else { // current machin lookup
            // nothing
        }
        
        urlComponents?.queryItems = queryItems
        
        guard let fullURL = urlComponents?.url else {
            throw LocatorErrors.internalError
        }
        
        var request = URLRequest(url: fullURL, cachePolicy: .useProtocolCachePolicy, timeoutInterval: timeout)
        request.httpMethod = httpMethod
        request.httpBody = httpBody
        return request
    }
    
    public func validateResponse(data: Data, httpResponse: HTTPURLResponse) -> LocatorErrors? {
        guard httpResponse.statusCode != 200 else {
            return nil
        }
        
        switch httpResponse.statusCode {
        // If your subscription is paused from use.
        // (1) If the provided API key is not valid.
        // (2) If your account has been disabled or locked by admin because of any illegal activity.
        // (3) If you’re making requests after your subscription trial has been expired.
        // (4) If you’ve exceeded your requests limit.
        // (5) If your subscription is not active.
        //(6) If you’re accessing a paid feature on free subscription.
        // (7) If you’re making a request without authorization with our IP Geolocation API.
        case 400, 401: return .usageLimitReached
        case 404: return .notFound // If the queried IP address or domain name is not found in our database.
        case 423: return .reserved // If the queried IP address is a bogon (reserved) IP address like private, multicast, etc.
        default:
            return .other(String(httpResponse.statusCode))
        }
        
    }
    
}
