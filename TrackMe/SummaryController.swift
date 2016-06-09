//
//  SecondViewController.swift
//  TrackMe
//
//  Created by HaoBoji on 3/05/2016.
//  Copyright © 2016 HaoBoji. All rights reserved.
//

import UIKit
import Charts
import CoreData
import CoreLocation
import HealthKit

class SummaryController: UIViewController, ChartViewDelegate {

    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var travelingDistanceChart: LineChartView!
    @IBOutlet var walkingDistanceChart: LineChartView!
    @IBOutlet var stepsCountChart: BarChartView!

    let healthStore = HKHealthStore()
    var managedObjectContext: NSManagedObjectContext
    let weekdays: [String] = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]
    let travelingDistances: [Double] = [1, 2, 3, 4, 5, 6, 7]
    var currentWeekStartDay: NSDate?
    var thisWeekStartDay: NSDate?

    let dateFormatter = NSDateFormatter()
    let titleDateFormatter = NSDateFormatter()

    required init?(coder aDecoder: NSCoder) {
        dateFormatter.dateFormat = "yyyy-MM-dd"
        titleDateFormatter.dateFormat = "MMM d"
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        self.managedObjectContext = appDelegate.managedObjectContext
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.backgroundColor = UIColor.whiteColor()
        initCharts()

        // Do any additional setup after loading the view, typically from a nib.
    }

    override func viewWillAppear(animated: Bool) {
        self.navigationItem.title = "This Week"
        thisWeekStartDay = calculateWeekStartDay(NSDate())
        currentWeekStartDay = calculateWeekStartDay(NSDate())

        // Traveling chart
        let weeklyLocations = fetchWeeklyLocations(thisWeekStartDay!)
        let weeklyTravelingDistances = calculateWeeklyTravelingDistances(weeklyLocations)
        print(weeklyTravelingDistances)
        setTravelingDistanceChartData(weeklyTravelingDistances)

        // Walking chart
        checkAvailability()
        let type = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDistanceWalkingRunning)
        fetchWeeklyHealthData(thisWeekStartDay!, type: type!, unit: HKUnit.meterUnit()) { weeklyHealthData in
            print(weeklyHealthData)
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func prevWeek(sender: UIBarButtonItem) {
        currentWeekStartDay = currentWeekStartDay!.dateByAddingTimeInterval(-24 * 60 * 60 * 7)
        printTitle()
        updateTravelingDistancesChart()
    }

    @IBAction func nextWeek(sender: UIBarButtonItem) {
        if (currentWeekStartDay!.isEqualToDate(thisWeekStartDay!)) {
            return
        }
        currentWeekStartDay = currentWeekStartDay!.dateByAddingTimeInterval(24 * 60 * 60 * 7)
        printTitle()
        updateTravelingDistancesChart()
    }

    func checkAvailability() -> Bool {
        var isAvailable = false
        if (!HKHealthStore.isHealthDataAvailable()) {
            return false
        }
        let stepsAndWalkingDistance = NSSet(objects: HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)!,
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDistanceWalkingRunning)!)
        healthStore.requestAuthorizationToShareTypes(nil, readTypes: stepsAndWalkingDistance as? Set<HKObjectType>) {
            (success, error) -> Void in
            isAvailable = success
        }
        return isAvailable
    }

    func printTitle() {
        if (currentWeekStartDay!.isEqualToDate(thisWeekStartDay!)) {
            self.navigationItem.title = "This Week"
        } else if (currentWeekStartDay!.dateByAddingTimeInterval(24 * 60 * 60 * 7).isEqualToDate(thisWeekStartDay!)) {
            self.navigationItem.title = "Last Week"
        } else {
            let currentWeekEndDay = currentWeekStartDay!.dateByAddingTimeInterval(24 * 60 * 60 * 6)
            self.navigationItem.title = titleDateFormatter.stringFromDate(currentWeekStartDay!) + "   to   "
                + titleDateFormatter.stringFromDate(currentWeekEndDay)
        }
    }

    func updateTravelingDistancesChart() {
        let weeklyLocations = fetchWeeklyLocations(currentWeekStartDay!)
        let weeklyTravelingDistances = calculateWeeklyTravelingDistances(weeklyLocations)
        setTravelingDistanceChartData(weeklyTravelingDistances)
    }

    func calculateWeeklyTravelingDistances(weeklyLocations: [NSArray]) -> [Double] {
        var travelingDistances: [Double] = [0, 0, 0, 0, 0, 0, 0]
        for dayCount: Int in 0..<7 {
            let dailyLocations = weeklyLocations[dayCount]
            let loopTimes = dailyLocations.count - 1
            if (loopTimes < 1) {
                continue
            }
            for locationCount: Int in 0..<loopTimes {
                let firstLocation = dailyLocations[locationCount] as! Location
                let secondLocation = dailyLocations[locationCount + 1] as! Location
                let first = CLLocation(latitude: firstLocation.latitude as! CLLocationDegrees,
                    longitude: firstLocation.longitude as! CLLocationDegrees)
                let second = CLLocation(latitude: secondLocation.latitude as! CLLocationDegrees,
                    longitude: secondLocation.longitude as! CLLocationDegrees)
                travelingDistances[dayCount] += first.distanceFromLocation(second)
            }
        }
        return travelingDistances
    }

    func calculateWeekStartDay(today: NSDate) -> NSDate {
        let adjust: Int = 1 - getDayOfWeek(today)
        let todayString = dateFormatter.stringFromDate(today)
        let startDay = dateFormatter.dateFromString(todayString)!
        currentWeekStartDay = startDay.dateByAddingTimeInterval(24 * 60 * 60 * Double(adjust))
        return currentWeekStartDay!
    }

    func fetchWeeklyLocations(startDate: NSDate) -> [NSArray] {
        var weeklyLocations = [NSArray](count: 7, repeatedValue: NSArray())
        for i: Int in 0..<7 {
            let fetchRequest = NSFetchRequest()
            let entityDescription = NSEntityDescription.entityForName("Location", inManagedObjectContext: self.managedObjectContext)
            let predicate: NSPredicate
            let firstDate = startDate.dateByAddingTimeInterval(60 * 60 * 24 * Double(i))
            let secondDate = firstDate.dateByAddingTimeInterval(60 * 60 * 24)
            predicate = NSPredicate(format: "(timestamp > %@) AND (timestamp < %@)", firstDate, secondDate)
            fetchRequest.entity = entityDescription
            fetchRequest.predicate = predicate
            var locations = NSArray()
            do {
                locations = try self.managedObjectContext.executeFetchRequest(fetchRequest)
            } catch {
                let fetchError = error as! NSError
                print(fetchError)
            }
            weeklyLocations[i] = locations
        }
        return weeklyLocations
    }

    func fetchWeeklyHealthData(startDate: NSDate, type: HKSampleType, unit: HKUnit, completion: [Double] -> ()) {
        let endDate = startDate.dateByAddingTimeInterval(60 * 60 * 24 * 7)
        let predicate = HKQuery.predicateForSamplesWithStartDate(startDate, endDate: endDate, options: .None)
        let query = HKSampleQuery(sampleType: type, predicate: predicate, limit: 0, sortDescriptors: nil,
            resultsHandler: { (query, results, error) in
                var weeklyHealthData: [Double] = [0, 0, 0, 0, 0, 0, 0]
                for result in results as! [HKQuantitySample] {
                    let index = self.getDayOfWeek(result.startDate) - 1
                    weeklyHealthData[index] += result.quantity.doubleValueForUnit(unit)
                }
                completion(weeklyHealthData)
        })
        healthStore.executeQuery(query)
    }

    func getDayOfWeek(day: NSDate) -> Int {
        let myCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        let myComponents = myCalendar.components(.Weekday, fromDate: day)
        let weekDay = myComponents.weekday
        return weekDay
    }

    func initCharts() {
        // Traveling chart
        travelingDistanceChart.noDataText = "No Traveling Data Provided."
        travelingDistanceChart.descriptionText = ""
        travelingDistanceChart.legend.enabled = false
        travelingDistanceChart.rightAxis.drawLabelsEnabled = false
        travelingDistanceChart.rightAxis.axisMinValue = 0
        travelingDistanceChart.leftAxis.axisMinValue = 0
        travelingDistanceChart.xAxis.labelPosition = .Bottom
        travelingDistanceChart.xAxis.drawGridLinesEnabled = false
        travelingDistanceChart.xAxis.setLabelsToSkip(0)
        // Walking chart
        walkingDistanceChart.noDataText = "No Walking Data Provided."
        walkingDistanceChart.descriptionText = ""
        walkingDistanceChart.legend.enabled = false
        walkingDistanceChart.rightAxis.drawLabelsEnabled = false
        walkingDistanceChart.rightAxis.axisMinValue = 0
        walkingDistanceChart.leftAxis.axisMinValue = 0
        walkingDistanceChart.xAxis.labelPosition = .Bottom
        walkingDistanceChart.xAxis.drawGridLinesEnabled = false
        walkingDistanceChart.xAxis.setLabelsToSkip(0)
    }

    func setTravelingDistanceChartData(travelingDistances: [Double]) {
        var yVals: [ChartDataEntry] = [ChartDataEntry]()
        for i in 0 ..< weekdays.count {
            yVals.append(ChartDataEntry(value: travelingDistances[i], xIndex: i))
        }
        let set1: LineChartDataSet = LineChartDataSet(yVals: yVals, label: "First Set")
        set1.axisDependency = .Left
        set1.setColor(UIColor.redColor().colorWithAlphaComponent(0.5))
        set1.setCircleColor(UIColor.redColor())
        set1.lineWidth = 2.0
        set1.circleRadius = 4.0
        set1.fillAlpha = 65 / 255.0
        set1.fillColor = UIColor.redColor()
        set1.drawFilledEnabled = true
        set1.highlightColor = UIColor.whiteColor()
        set1.drawCircleHoleEnabled = true
        set1.mode = .CubicBezier
        set1.cubicIntensity = 0.2
        var dataSets: [LineChartDataSet] = [LineChartDataSet]()
        dataSets.append(set1)
        let data: LineChartData = LineChartData(xVals: weekdays, dataSets: dataSets)
        self.travelingDistanceChart.data = data
    }
}
