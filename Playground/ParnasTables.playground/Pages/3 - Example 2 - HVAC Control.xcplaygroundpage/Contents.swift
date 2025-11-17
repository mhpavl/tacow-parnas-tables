//: [Previous: Access Control](@previous)
//:
//: # Example 2: HVAC Temperature Control
//:
//: ## The Challenge
//: HVAC systems consider both **temperature** AND **humidity** - a two-dimensional decision space.
//:
//: ## Incomplete Table (Has Bugs!)
//:
//: ```
//: ┌──────────────────┬──────────────┬─────────────────────┐
//: │ Temperature (°C) │ Humidity (%) │ Action              │
//: ├──────────────────┼──────────────┼─────────────────────┤
//: │ < 0              │ *            │ Heat + Humidify     │
//: │ 0-20             │ 40-60        │ Heat                │
//: │ 20-25            │ 40-60        │ OFF                 │
//: │ >25              │ >60          │ Cool + Dehumidify   │
//: └──────────────────┴──────────────┴─────────────────────┘
//: ```
//:
//: **Missing cases:**
//: * 0-20°C with humidity <40% or >60%
//: * 20-25°C with humidity <40% or >60%
//: * >25°C with humidity ≤60%
//: * Boundaries overlap (is 20 in row 2 or 3?)
//:
//: ## Complete Table (Fixed)
//:
//: ```
//: ┌──────────────────┬──────────────┬─────────────────────┐
//: │ Temperature (°C) │ Humidity (%) │ Action              │
//: ├──────────────────┼──────────────┼─────────────────────┤
//: │ < 0              │ *            │ Heat + Humidify     │
//: │ [0, 20)          │ < 40         │ Heat + Humidify     │
//: │ [0, 20)          │ [40, 60]     │ Heat                │
//: │ [0, 20)          │ > 60         │ Heat                │
//: │ [20, 25)         │ < 40         │ Humidify            │
//: │ [20, 25)         │ [40, 60]     │ OFF                 │
//: │ [20, 25)         │ > 60         │ Dehumidify          │
//: │ ≥ 25             │ ≤ 60         │ Cool                │
//: │ ≥ 25             │ > 60         │ Cool + Dehumidify   │
//: └──────────────────┴──────────────┴─────────────────────┘
//: ```
//:
//: > **Note:** Every temperature/humidity combination is now covered with clear, non-overlapping boundaries.
//:

import Foundation

print("=" + String(repeating: "=", count: 70))
print("EXAMPLE 2: HVAC TEMPERATURE CONTROL")
print("=" + String(repeating: "=", count: 70) + "\n")

enum HVACAction: CustomStringConvertible {
    case heat
    case cool
    case humidify
    case dehumidify
    case heatAndHumidify
    case coolAndDehumidify
    case off
    
    var description: String {
        switch self {
        case .heat: return "Heat"
        case .cool: return "Cool"
        case .humidify: return "Humidify"
        case .dehumidify: return "Dehumidify"
        case .heatAndHumidify: return "Heat + Humidify"
        case .coolAndDehumidify: return "Cool + Dehumidify"
        case .off: return "OFF"
        }
    }
}

//: ## Range Syntax in Swift
//: * `..<20` means "less than 20" → [0, 20)
//: * `40...60` means "40 through 60" → [40, 60]
//: * `60...` means "60 and above" → [60, ∞)
//: * `...60` means "60 and below" → (-∞, 60]

func determineHVACAction(temperatureCelsius: Double, humidityPercent: Double) -> HVACAction {
    switch (temperatureCelsius, humidityPercent) {
    // Below freezing
    case (..<0, _):
        return .heatAndHumidify
    
    // Cold range [0, 20)
    case (0..<20, ..<50):
        return .heatAndHumidify
    case (0..<20, 40...60):
        return .heat
    case (0..<20, 60...):
        return .heat
    
    // Comfortable range [20, 25) - humidity control matters
    case (20..<25, ..<40):
        return .humidify
    case (20..<25, 40...60):
        return .off
    case (20..<25, 60...):
        return .dehumidify
    
    // Hot range [25, ∞)
    case (25..., ...60):
        return .cool
    case (25..., 60...):
        return .coolAndDehumidify
        
    default:
        // Swift cannot check numeric ranges (yet) for completeness like it can types
        fatalError("Mathematically impossible case")
    }
}

//: ## Test Results

let hvacTestCases: [(Double, Double)] = [
    (-5, 50),     // Freezing
    (5, 30),      // Cold, dry
    (15, 50),     // Cold, normal
    (15, 70),     // Cold, humid
    (22, 35),     // Comfortable, low humidity
    (22, 50),     // Comfortable, normal
    (22, 75),     // Comfortable, high humidity
    (28, 50),     // Hot, normal
    (28, 75),     // Hot, humid
]

for (temp, humidity) in hvacTestCases {
    let action = determineHVACAction(temperatureCelsius: temp, humidityPercent: humidity)
    print("Temp: \(String(format: "%5.1f", temp))°C, Humidity: \(String(format: "%5.1f", humidity))% → \(action)")
}

print("\n")

//: ## Key Takeaways
//:
//: * **Continuous input spaces** require careful boundary definition
//: * **Disjointness is critical:** Use `[0, 20)` and `[20, 25)` to avoid overlap at 20
//: * **Complete coverage:** Every point in the temperature × humidity plane has exactly one action
//: * **Domain-specific logic:** Humidity matters differently at different temperatures
//: * **Limitation:** Swift can't verify numeric range completeness automatically - YOU must ensure it
//:
//: ## The Bug We Caught
//:
//: The original incomplete table would have caused runtime errors or wrong behavior for many common scenarios:
//: * Cold room with low humidity → undefined behavior
//: * Comfortable temperature but too humid → no dehumidification
//: * Hot room with normal humidity → system stays off
//:
//: By creating a complete table first, we caught these bugs **before writing any code**!
//:
//: ---
//:
//: [Next: Order Processing](@next)
