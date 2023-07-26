//
// This source file is part of the Stanford HealthGPT project
//
// SPDX-FileCopyrightText: 2023 Stanford University & Project Contributors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import HealthKit

class HealthDataFetcher {
    private let healthStore = HKHealthStore()

    /// Requests authorization to access the user's health data.
    ///
    /// - Returns: A `Bool` value indicating whether the authorization was successful.
    func requestAuthorization() async throws {
        guard HKHealthStore.isHealthDataAvailable() else {
            throw HKError(.errorHealthDataUnavailable)
        }

        let types: Set<HKObjectType> = [
            HKObjectType.characteristicType(forIdentifier: .biologicalSex)!,
            HKQuantityType.quantityType(forIdentifier: .stepCount)!,
            HKQuantityType.quantityType(forIdentifier: .appleExerciseTime)!,
            HKQuantityType.quantityType(forIdentifier: .bodyMass)!,
            HKQuantityType.quantityType(forIdentifier: .heartRate)!,
            HKQuantityType.quantityType(forIdentifier: .restingHeartRate)!,
            HKQuantityType.quantityType(forIdentifier: .bloodPressureSystolic)!,
            HKQuantityType.quantityType(forIdentifier: .bloodPressureDiastolic)!,
            HKCategoryType.categoryType(forIdentifier: .sleepAnalysis)!
        ]

        try await healthStore.requestAuthorization(toShare: Set<HKSampleType>(), read: types)
    }
    
    /// Fetches the user's biological sex.
    ///
    /// - Returns: The `HKBiologicalSex` value representing the user's biological sex.
    /// - Throws: `HealthDataFetcherError` if the data cannot be fetched.
    func fetchBiologicalSex() async throws -> String {
        return try await withCheckedThrowingContinuation { continuation in
            do {
                let biologicalSexObject = try healthStore.biologicalSex()
                let biologicalSex = biologicalSexObject.biologicalSex

                // Convert HKBiologicalSex to a string representation
                var biologicalSexString = ""

                switch biologicalSex {
                case .notSet:
                    print("Biological sex is not set in HealthKit.")
                    biologicalSexString = "Not Set"
                case .female:
                    print("Biological sex retrieved from HealthKit: Female.")
                    biologicalSexString = "Female"
                case .male:
                    print("Biological sex retrieved from HealthKit: Male.")
                    biologicalSexString = "Male"
                case .other:
                    print("Biological sex retrieved from HealthKit: Other.")
                    biologicalSexString = "Other"
                @unknown default:
                    print("Biological sex retrieved from HealthKit: Unknown value.")
                    biologicalSexString = "Unknown"
                }

                continuation.resume(returning: biologicalSexString)
            } catch {
                print("Error fetching biological sex from HealthKit: \(error.localizedDescription)")
                continuation.resume(throwing: error)
            }
        }
    }

    /// Fetches the user's health data for the specified quantity type identifier for the last two weeks.
    ///
    /// - Parameters:
    ///   - identifier: The `HKQuantityTypeIdentifier` representing the type of health data to fetch.
    ///   - unit: The `HKUnit` to use for the fetched health data values.
    ///   - options: The `HKStatisticsOptions` to use when fetching the health data.
    /// - Returns: An array of `Double` values representing the daily health data for the specified identifier.
    /// - Throws: `HealthDataFetcherError` if the data cannot be fetched.
    func fetchLastTwoWeeksQuantityData(
        for identifier: HKQuantityTypeIdentifier,
        unit: HKUnit,
        options: HKStatisticsOptions
    ) async throws -> [Double] {
        guard let quantityType = HKObjectType.quantityType(forIdentifier: identifier) else {
            throw HealthDataFetcherError.invalidObjectType
        }

        let predicate = createLastTwoWeeksPredicate()

        let quantityLastTwoWeeks = HKSamplePredicate.quantitySample(
            type: quantityType,
            predicate: predicate
        )

        let query = HKStatisticsCollectionQueryDescriptor(
            predicate: quantityLastTwoWeeks,
            options: options,
            anchorDate: Date.startOfDay(),
            intervalComponents: DateComponents(day: 1)
        )

        let quantityCounts = try await query.result(for: healthStore)

        var dailyData = [Double]()

        quantityCounts.enumerateStatistics(
            from: Date().twoWeeksAgoStartOfDay(),
            to: Date.startOfDay()
        ) { statistics, _ in
            if let quantityValue = statistics.sumQuantity()?.doubleValue(for: unit) {
                print("Date: \(statistics.startDate), \(identifier.rawValue): \(quantityValue)")
                dailyData.append(quantityValue)
            } else {
                print("Date: \(statistics.startDate), \(identifier.rawValue): None")
                dailyData.append(0)
            }
        }

        return dailyData
    }

    /// Fetches the user's step count data for the last two weeks.
    ///
    /// - Returns: An array of `Double` values representing daily step counts.
    /// - Throws: `HealthDataFetcherError` if the data cannot be fetched.
    func fetchLastTwoWeeksStepCount() async throws -> [Double] {
        try await fetchLastTwoWeeksQuantityData(
            for: .stepCount,
            unit: HKUnit.count(),
            options: [.cumulativeSum]
        )
    }

    /// Fetches the user's active energy burned data for the last two weeks.
    ///
    /// - Returns: An array of `Double` values representing daily active energy burned.
    /// - Throws: `HealthDataFetcherError` if the data cannot be fetched.
    func fetchLastTwoWeeksActiveEnergy() async throws -> [Double] {
        try await fetchLastTwoWeeksQuantityData(
            for: .activeEnergyBurned,
            unit: HKUnit.largeCalorie(),
            options: [.cumulativeSum]
        )
    }

    /// Fetches the user's exercise time data for the last two weeks.
    ///
    /// - Returns: An array of `Double` values representing daily exercise times in minutes.
    /// - Throws: `HealthDataFetcherError` if the data cannot be fetched.
    func fetchLastTwoWeeksExerciseTime() async throws -> [Double] {
        try await fetchLastTwoWeeksQuantityData(
            for: .appleExerciseTime,
            unit: .minute(),
            options: [.cumulativeSum]
        )
    }

    /// Fetches the user's body weight data for the last two weeks.
    ///
    /// - Returns: An array of `Double` values representing daily body weights in pounds.
    /// - Throws: `HealthDataFetcherError` if the data cannot be fetched.
    func fetchLastTwoWeeksBodyWeight() async throws -> [Double] {
        try await fetchLastTwoWeeksQuantityData(
            for: .bodyMass,
            unit: .pound(),
            options: [.discreteAverage]
        )
    }
    
//    func fetchLatestHeartRateSample(completion: @escaping (HKQuantitySample?, Error?) -> Swift.Void) {
//        let sampleType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!
//        let predicate = HKQuery.predicateForSamples(withStart: Date.distantPast, end: Date(), options: .strictStartDate)
//        
//        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
//        
//        let query = HKSampleQuery(sampleType: sampleType, predicate: predicate, limit: 1, sortDescriptors: [sortDescriptor]) { (_, results, error) in
//            if let sample = results?.first as? HKQuantitySample {
//                completion(sample, nil)
//            } else {
//                completion(nil, error)
//            }
//        }
//        
//        healthStore.execute(query)
//    }

    /// Converts a Unix timestamp to a Date object.
    func convertTimestampToDate(timestamp: Double) -> Date {
        // Convert the timestamp from the UNIX epoch (1970) rather than the macOS epoch (2001)
        return Date(timeIntervalSince1970: timestamp)
    }
    
    /// Fetches the user's heart rate samples for the last two weeks.
    ///
    /// - Returns: A dictionary with `Date` keys and an array of `Double` values representing all heart rate samples for each day.
    /// - Throws: `HealthDataFetcherError` if the data cannot be fetched.
    func fetchLastTwoWeeksHeartRate() async throws -> [Date: [Double]] {
        print("Starting heart rate samples fetch...")

        guard let quantityType = HKObjectType.quantityType(forIdentifier: .heartRate) else {
            throw HealthDataFetcherError.invalidObjectType
        }

        let endDate = Date()
        let startDate = Calendar.current.date(byAdding: .day, value: -14, to: endDate)!

        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: quantityType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)]
            ) { (query: HKSampleQuery, samples: [HKSample]?, error: Error?) in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                var dailySamples: [Date: [Double]] = [:]

                for sample in samples as! [HKQuantitySample] {
                    let date = Calendar.current.startOfDay(for: sample.startDate)
                    let heartRateValue = sample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: HKUnit.minute()))

                    if dailySamples[date] == nil {
                        dailySamples[date] = []
                    }
                    dailySamples[date]!.append(heartRateValue)
                }

                continuation.resume(returning: dailySamples)
            }
            healthStore.execute(query)
        }
    }
    
    func fetchLastTwoWeeksRestingHeartRate() async throws -> [Double] {
        try await fetchLastTwoWeeksQuantityData(
            for: .restingHeartRate,
            unit: HKUnit.count().unitDivided(by: HKUnit.minute()),
            options: [.discreteAverage]
        )
    }

    /// Fetches the user's sleep data for the last two weeks.
    ///
    /// - Returns: An array of `Double` values representing daily sleep duration in hours.
    /// - Throws: `HealthDataFetcherError` if the data cannot be fetched.
    func fetchLastTwoWeeksSleep() async throws -> [Double] {
        var dailySleepData: [Double] = []
        
        // We go through all possible days in the last two weeks.
        for day in -14..<0 {
            // We start the calculation at 3 PM the previous day to 3 PM on the day in question.
            guard let startOfSleepDay = Calendar.current.date(byAdding: DateComponents(day: day - 1), to: Date.startOfDay()),
                  let startOfSleep = Calendar.current.date(bySettingHour: 15, minute: 0, second: 0, of: startOfSleepDay),
                  let endOfSleepDay = Calendar.current.date(byAdding: DateComponents(day: day), to: Date.startOfDay()),
                  let endOfSleep = Calendar.current.date(bySettingHour: 15, minute: 0, second: 0, of: endOfSleepDay) else {
                dailySleepData.append(0)
                continue
            }
            
            
            let sleepType = HKCategoryType(.sleepAnalysis)

            let dateRangePredicate = HKQuery.predicateForSamples(withStart: startOfSleep, end: endOfSleep, options: .strictEndDate)
            let allAsleepValuesPredicate = HKCategoryValueSleepAnalysis.predicateForSamples(equalTo: HKCategoryValueSleepAnalysis.allAsleepValues)
            let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [dateRangePredicate, allAsleepValuesPredicate])

            let descriptor = HKSampleQueryDescriptor(
                predicates: [.categorySample(type: sleepType, predicate: compoundPredicate)],
                sortDescriptors: []
            )
            
            let results = try await descriptor.result(for: healthStore)

            var secondsAsleep = 0.0
            for result in results {
                secondsAsleep += result.endDate.timeIntervalSince(result.startDate)
            }
            
            // Append the hours of sleep for that date
            dailySleepData.append(secondsAsleep / (60 * 60))
        }
        
        return dailySleepData
    }
    
    /// Fetches the user's blood pressure data for the last two weeks.
    ///
    /// - Returns: An array of tuples representing daily systolic and diastolic blood pressures.
    /// - Throws: `HealthDataFetcherError` if the data cannot be fetched.
    func fetchLastTwoWeeksBloodPressure() async throws -> [Date: [(systolic: Double, diastolic: Double)]] {
        return try await withCheckedThrowingContinuation { continuation in
            var dailyData: [Date: [(systolic: Double, diastolic: Double)]] = [:]

            let predicate = createLastTwoWeeksPredicate()
            let bloodPressureType = HKCorrelationType.correlationType(forIdentifier: .bloodPressure)!

            let query = HKSampleQuery(
                sampleType: bloodPressureType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)]
            ) { _, samples, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                for sample in samples as! [HKCorrelation] {
                    let date = sample.startDate
                    let systolicSample = sample.objects(for: HKQuantityType.quantityType(forIdentifier: .bloodPressureSystolic)!).first as! HKQuantitySample
                    let diastolicSample = sample.objects(for: HKQuantityType.quantityType(forIdentifier: .bloodPressureDiastolic)!).first as! HKQuantitySample
                    
                    let systolicValue = systolicSample.quantity.doubleValue(for: HKUnit.millimeterOfMercury())
                    let diastolicValue = diastolicSample.quantity.doubleValue(for: HKUnit.millimeterOfMercury())
                    
                    if dailyData[date] == nil {
                        dailyData[date] = []
                    }
                    dailyData[date]!.append((systolic: systolicValue, diastolic: diastolicValue))
                }
                continuation.resume(returning: dailyData)
            }

            healthStore.execute(query)
        }
    }

//    private func createLastTwoWeeksPredicate() -> NSPredicate {
//        let now = Date()
//        let startDate = Calendar.current.date(byAdding: DateComponents(day: -14), to: now) ?? Date()
//        return HKQuery.predicateForSamples(withStart: startDate, end: now, options: .strictStartDate)
//    }
    
    private func createLastTwoWeeksPredicate() -> NSPredicate {
        let endDate = Date()
        let startDate = Calendar.current.date(byAdding: .day, value: -14, to: endDate)!

        print("Calculated Start Date: \(startDate)")
        print("Calculated End Date: \(endDate)")

        return HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
    }
}
