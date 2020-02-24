/** Moon phase utils.
Ported from https://github.com/mourner/suncalc
Maksym Huk 2017 https://gist.github.com/capt-hook/7a3d1fd889e5cc9dca4cc13afb85c3a0
*/

import Foundation

class Moon {
    static let shared = Moon()
    
    let rad = Double.pi / 180
    
    let daySeconds: TimeInterval = 60 * 60 * 24
    let J1970: Double = 2440588
    let J2000: Double = 2451545
    
    let e = (Double.pi / 180) * 23.4397 // obliquity of the Earth
    
    func toJulian(_ date: Date) -> TimeInterval {
        return date.timeIntervalSince1970 / daySeconds - 0.5 + J1970
    }
    
    func fromJulian(_ j: TimeInterval) -> Date {
        return Date(timeIntervalSince1970: (j + 0.5 - J1970) * daySeconds)
    }
    
    func toDays(_ date: Date) -> TimeInterval {
        return toJulian(date) - J2000
    }
    
    func rightAscension(_ l: Double, _ b: Double) -> Double {
        return atan2(sin(l) * cos(e) - tan(b) * sin(e), cos(l))
    }
    
    func declination(_ l: Double, _ b: Double) -> Double {
        return asin(sin(b) * cos(e) + cos(b) * sin(e) * sin(l))
    }
    
    func solarMeanAnomaly(_ d: TimeInterval) -> Double {
        return rad * (357.5291 + 0.98560028 * d)
    }
    
    func eclipticLongitude(_ M: Double) -> Double {
        let C = rad * (1.9148 * sin(M) + 0.02 * sin(2 * M) + 0.0003 * sin(3 * M)) // equation of center
        let P = rad * 102.9372 // perihelion of the Earth
        
        return M + C + P + Double.pi
    }
    
    struct SunCoords {
        let dec: Double
        let ra: Double
    }
    
    func sunCoords(_ d: TimeInterval) -> SunCoords {
        let M = solarMeanAnomaly(d)
        let L = eclipticLongitude(M)
        
        return SunCoords(
            dec: declination(L, 0),
            ra: rightAscension(L, 0)
        )
    }
    
    struct MoonCoords {
        let ra: Double
        let dec: Double
        let dist: Double
    }
    
    func moonCoords(_ d: TimeInterval) -> MoonCoords { // geocentric ecliptic coordinates of the moon
        let L = rad * (218.316 + 13.176396 * d) // ecliptic longitude
        let M = rad * (134.963 + 13.064993 * d) // mean anomaly
        let F = rad * (93.272 + 13.229350 * d)  // mean distance
        
        let l  = L + rad * 6.289 * sin(M) // longitude
        let b  = rad * 5.128 * sin(F)     // latitude
        let dt = 385001 - 20905 * cos(M)  // distance to the moon in km
        
        return MoonCoords(
            ra: rightAscension(l, b),
            dec: declination(l, b),
            dist: dt
        )
    }
    
    struct Illumination {
        let fraction: Double
        let phase: Double
        let angle: Double
    }
    
    func illumination(date: Date!) -> Illumination {
        let d = toDays(date ?? Date.currentDate)
        let s = sunCoords(d)
        let m = moonCoords(d)
        
        let sdist: Double = 149598000 // distance from Earth to Sun in km
        
        let phi = acos(sin(s.dec) * sin(m.dec) + cos(s.dec) * cos(m.dec) * cos(s.ra - m.ra))
        let inc = atan2(sdist * sin(phi), m.dist - sdist * cos(phi))
        let angle = atan2(cos(s.dec) * sin(s.ra - m.ra), sin(s.dec) * cos(m.dec) -
            cos(s.dec) * sin(m.dec) * cos(s.ra - m.ra))
        
        return Illumination(
            fraction: (1 + cos(inc)) / 2,
            phase: 0.5 + 0.5 * inc * (angle < 0 ? -1 : 1) / Double.pi,
            angle: angle
        )
    }
}
