//
// This source file is part of the Stanford HealthGPT project
//
// SPDX-FileCopyrightText: 2023 Stanford University & Project Contributors
//
// SPDX-License-Identifier: MIT
//

import Foundation

struct BloodPressureReading: Codable {
    var systolic: Double
    var diastolic: Double
}

struct HealthData: Codable {
    var date: String  // Represents the date for the entire health data of the day.
    var biologicalSex: String
    var steps: Double?
    var activeEnergy: Double?
    var exerciseMinutes: Double?
    var bodyWeight: Double?
    var sleepHours: Double?
    var heartRate: Double?
    var restingHeartRate: Double?
    var bloodPressures: [BloodPressureReading]?
}
