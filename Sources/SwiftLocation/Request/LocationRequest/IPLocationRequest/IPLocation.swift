//
//  File.swift
//  
//
//  Created by daniele on 26/09/2020.
//

import Foundation
import CoreLocation

public struct IPLocation: Decodable, CustomStringConvertible {
    
    public enum Keys {
        case hostname
        case continent
        case continentCode
        case country
        case countryCode
        case region
        case regionCode
        case city
        case postalCode
        case district
        case timezone
        case isp
    }
    
    public let coordinates: CLLocationCoordinate2D
    public private(set) var info = [Keys: String?]()
    public let ip: String

    public init(from decoder: Decoder) throws {
        guard let decoderService = decoder.userInfo[IPServiceDecoder] as? IPServiceDecoders else {
            throw LocatorErrors.parsingError
        }
        
        switch decoderService {
        case .ipstack:
            let container = try decoder.container(keyedBy: IPStackCodingKeys.self)
            
            self.ip = try container.decode(String.self, forKey: .ip)
            
            let latitude = try container.decode(CLLocationDegrees.self, forKey: .latitude)
            let longitude = try container.decode(CLLocationDegrees.self, forKey: .longitude)
            self.coordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            
            self.info[Keys.hostname] = try container.decodeIfPresent(String.self, forKey: .hostname)
            
            self.info[Keys.continent] = try container.decodeIfPresent(String.self, forKey: .continent)
            self.info[Keys.continentCode] = try container.decodeIfPresent(String.self, forKey: .continentCode)
            
            self.info[Keys.country] = try container.decodeIfPresent(String.self, forKey: .country)
            self.info[Keys.countryCode] = try container.decodeIfPresent(String.self, forKey: .countryCode)
            
            self.info[Keys.region] = try container.decodeIfPresent(String.self, forKey: .region)
            self.info[Keys.regionCode] = try container.decodeIfPresent(String.self, forKey: .regionCode)
            
        case .ipdata:
            let container = try decoder.container(keyedBy: IPDataCodingKeys.self)

            self.ip = try container.decode(String.self, forKey: .ip)
         
            let latitude = try container.decode(CLLocationDegrees.self, forKey: .latitude)
            let longitude = try container.decode(CLLocationDegrees.self, forKey: .longitude)
            self.coordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            
            self.info[Keys.continent] = try container.decodeIfPresent(String.self, forKey: .continent)
            self.info[Keys.continentCode] = try container.decodeIfPresent(String.self, forKey: .continentCode)
            
            self.info[Keys.country] = try container.decodeIfPresent(String.self, forKey: .country)
            self.info[Keys.countryCode] = try container.decodeIfPresent(String.self, forKey: .countryCode)
            
            self.info[Keys.region] = try container.decodeIfPresent(String.self, forKey: .region)
            self.info[Keys.regionCode] = try container.decodeIfPresent(String.self, forKey: .regionCode)
            
            self.info[Keys.city] = try container.decodeIfPresent(String.self, forKey: .city)
            self.info[Keys.postalCode] = try container.decodeIfPresent(String.self, forKey: .postalCode)
            
        case .ipinfo:
            let container = try decoder.container(keyedBy: IPInfoCodingKeys.self)

            self.ip = try container.decode(String.self, forKey: .ip)

            let coords = try container.decode(String.self, forKey: .loc).components(separatedBy: ",")
            self.coordinates = CLLocationCoordinate2D(latitude: CLLocationDegrees(coords.first ?? "0") ?? 0,
                                                      longitude: CLLocationDegrees(coords.last ?? "0") ?? 0)

            self.info[Keys.country] = try container.decodeIfPresent(String.self, forKey: .country)
            self.info[Keys.region] = try container.decodeIfPresent(String.self, forKey: .region)
            self.info[Keys.postalCode] = try container.decodeIfPresent(String.self, forKey: .postal)
            
        case .ipapi:
            let container = try decoder.container(keyedBy: IPApiCodingKeys.self)

            self.ip = try container.decode(String.self, forKey: .ip)
            
            let latitude = try container.decode(CLLocationDegrees.self, forKey: .latitude)
            let longitude = try container.decode(CLLocationDegrees.self, forKey: .longitude)
            self.coordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            
            self.info[Keys.continent] = try container.decodeIfPresent(String.self, forKey: .continent)
            self.info[Keys.continentCode] = try container.decodeIfPresent(String.self, forKey: .continentCode)
      
            self.info[Keys.country] = try container.decodeIfPresent(String.self, forKey: .country)
            self.info[Keys.countryCode] = try container.decodeIfPresent(String.self, forKey: .countryCode)
         
            self.info[Keys.region] = try container.decodeIfPresent(String.self, forKey: .region)
            self.info[Keys.regionCode] = try container.decodeIfPresent(String.self, forKey: .regionCode)
        
            self.info[Keys.city] = try container.decodeIfPresent(String.self, forKey: .city)
            self.info[Keys.postalCode] = try container.decodeIfPresent(String.self, forKey: .postalCode)
            self.info[Keys.district] = try container.decodeIfPresent(String.self, forKey: .district)
            
            self.info[Keys.timezone] = try container.decodeIfPresent(String.self, forKey: .timezone)
            self.info[Keys.isp] = try container.decodeIfPresent(String.self, forKey: .isp)
            
        case .ipgeolocation:
            let container = try decoder.container(keyedBy: IPGeolocationCodingKeys.self)

            self.ip = try container.decode(String.self, forKey: .ip)
            self.info[Keys.hostname] = try container.decodeIfPresent(String.self, forKey: .hostname)
            
            let latitude = try container.decode(String.self, forKey: .latitude)
            let longitude = try container.decode(String.self, forKey: .longitude)
            self.coordinates = CLLocationCoordinate2D(latitude: CLLocationDegrees(latitude) ?? 0,
                                                      longitude: CLLocationDegrees(longitude) ?? 0)
            
            self.info[Keys.continent] = try container.decodeIfPresent(String.self, forKey: .continent)
            self.info[Keys.continentCode] = try container.decodeIfPresent(String.self, forKey: .continentCode)
            
            self.info[Keys.country] = try container.decodeIfPresent(String.self, forKey: .country)
            self.info[Keys.countryCode] = try container.decodeIfPresent(String.self, forKey: .countryCode)

            self.info[Keys.city] = try container.decodeIfPresent(String.self, forKey: .city)
            self.info[Keys.postalCode] = try container.decodeIfPresent(String.self, forKey: .postalCode)
            self.info[Keys.district] = try container.decodeIfPresent(String.self, forKey: .district)
            
            self.info[Keys.isp] = try container.decodeIfPresent(String.self, forKey: .isp)
        }
    }
    
    // MARK: - IPGeolocationCodingKeys
    
    private enum IPGeolocationCodingKeys: String, CodingKey {
        case ip, hostname, continent = "continent_name", continentCode = "continent_code",
             country = "country_name", countryCode = "country_code2",
             district = "district",
             city, postalCode = "zipcode",
             latitude, longitude,
             isp
    }
    
    // MARK: - IPApi
    
    private enum IPApiCodingKeys: String, CodingKey {
        case ip = "query",
             latitude = "lat", longitude = "lon",
             continent, continentCode,
             country, countryCode,
             region, regionCode,
             city, postalCode = "zip",
             district,
             timezone,
             isp
    }
    
    // MARK: - IPInfo
    
    private enum IPInfoCodingKeys: String, CodingKey {
        case ip, city, region, country, loc, postal
    }
    
    // MARK: - IPData
    
    private enum IPDataCodingKeys: String, CodingKey {
        case ip,
             city,
             latitude, longitude,
             postalCode = "postal",
             continent = "continent_name", continentCode = "continent_code",
             country = "country_name", countryCode = "country_code",
             region = "region", regionCode = "region_code"
    }
        
    // MARK: - IPStack
    
    private enum IPStackCodingKeys: String, CodingKey {
        case latitude,
             longitude,
             hostname,
             ip,
             continent = "continent_name", continentCode = "continent_code",
             country = "country_name", countryCode = "country_code",
             region = "region_name", regionCode = "region_code"
    }
    
    public var description: String {
        return "{lat=\(coordinates.latitude), lng=\(coordinates.longitude), info=\(info)}"
    }
        
}
