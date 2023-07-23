//
// This source file is part of the Stanford HealthGPT project
//
// SPDX-FileCopyrightText: 2023 Stanford University & Project Contributors
//
// SPDX-License-Identifier: MIT
//


import Foundation


extension HealthDataFetcher {
    /// Fetches and processes health data for the last 14 days.
    ///
    /// - Returns: An array of `HealthData` objects, one for each day in the last 14 days.
    ///
    /// - Throws: `HealthDataFetcherError.authorizationFailed` if health data authorization fails.
    func fetchAndProcessHealthData() async throws -> [HealthData] {
        try await requestAuthorization()

        let calendar = Calendar.current
        let today = Date()
        var healthData: [HealthData] = []

        // Create an array of HealthData objects for the last 14 days
        for day in 1...14 {
             guard let endDate = calendar.date(byAdding: .day, value: -day, to: today) else { continue }
             healthData.append(
                 HealthData(
                     date: DateFormatter.localizedString(from: endDate, dateStyle: .short, timeStyle: .none),
                     biologicalSex: "" // Initialize with an empty string. We will update it later.
                 )
             )
         }

        healthData = healthData.reversed()

        print("Processed Health Data: \(healthData)")
        
        async let biologicalSex = fetchBiologicalSex()
        async let stepCounts = fetchLastTwoWeeksStepCount()
        async let sleepHours = fetchLastTwoWeeksSleep()
        async let caloriesBurned = fetchLastTwoWeeksActiveEnergy()
        async let exerciseTime = fetchLastTwoWeeksExerciseTime()
        async let bodyMass = fetchLastTwoWeeksBodyWeight()
        async let heartRates = fetchLastTwoWeeksHeartRate()
        async let restingHeartRates = fetchLastTwoWeeksRestingHeartRate()
        async let bloodPressures = fetchLastTwoWeeksBloodPressure()

        let fetchedBiologicalSex = try? await biologicalSex
        let fetchedStepCounts = try? await stepCounts
        let fetchedSleepHours = try? await sleepHours
        let fetchedCaloriesBurned = try? await caloriesBurned
        let fetchedExerciseTime = try? await exerciseTime
        let fetchedBodyMass = try? await bodyMass
        let fetchedHeartRates = try? await heartRates
        let fetchedRestingHeartRates = try? await restingHeartRates
        let fetchedBloodPressures = try? await bloodPressures
        
        // Update biological sex for all entries (since it's the same value for all days)
        for index in 0..<healthData.count {
            healthData[index].biologicalSex = fetchedBiologicalSex ?? "Not Set"
        }

        print("Fetched Blood Pressures Directly After Fetching: \(String(describing: fetchedBloodPressures))")

        for day in 0...13 {
            guard let currentDate = calendar.date(byAdding: .day, value: -day, to: today) else { continue }

            // Normalize the date to the start of the day
            let startOfDayDate = calendar.startOfDay(for: currentDate)
            
            print("Checking for date: \(startOfDayDate)")

            healthData[day].steps = fetchedStepCounts?[day]
            healthData[day].sleepHours = fetchedSleepHours?[day]
            healthData[day].activeEnergy = fetchedCaloriesBurned?[day]
            healthData[day].exerciseMinutes = fetchedExerciseTime?[day]
            healthData[day].bodyWeight = fetchedBodyMass?[day]
            healthData[day].heartRate = fetchedHeartRates?[day]
            healthData[day].restingHeartRate = fetchedRestingHeartRates?[day]

            // Match based on the start of the day
            for (date, readings) in fetchedBloodPressures ?? [:] {
                if let index = healthData.firstIndex(where: { $0.date == DateFormatter.localizedString(from: date, dateStyle: .short, timeStyle: .none) }) {
                    healthData[index].bloodPressures = readings.map { BloodPressureReading(systolic: $0.systolic, diastolic: $0.diastolic) }
                }
            }
        }

        return healthData
    }
}
