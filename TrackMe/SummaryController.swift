//
//  SecondViewController.swift
//  TrackMe
//
//  Created by HaoBoji on 3/05/2016.
//  Copyright © 2016 HaoBoji. All rights reserved.
//

import UIKit
import Charts

class SummaryController: UIViewController {

    @IBOutlet var movingDistanceChart: LineChartView!

    override func viewDidLoad() {
        super.viewDidLoad()
        movingDistanceChart.noDataText = "No Data"
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
