//
//  ViewController.swift
//  Barceloneta
//
//  Created by Arnaud Schloune on 17/05/16.
//  Copyright © 2016 Arnaud Schloune. All rights reserved.
//

import UIKit

class ViewController: UIViewController, BarcelonetaDelegate {

    @IBOutlet weak var barcelonetaView: Barceloneta!
    @IBOutlet weak var bcnViewVerticalConstraint: NSLayoutConstraint!
    @IBOutlet weak var bcnViewHorizontalConstraint: NSLayoutConstraint!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        barcelonetaView.layer.cornerRadius = 6.0
        barcelonetaView.timerSettings = [
            (range:0..<70, timer:0.3, increment:1.0),
            (range:70..<120, timer:0.2, increment:2.0),
            (range:120..<500, timer:0.1, increment:3.0)
        ]
        enable(withAxis: .horizontal)
    }
    override func viewWillAppear(_ animated: Bool) {
        //Set the default background color
        animateBarcelonetaBackgroundColor(color(forMinimalRange: 0))
        barcelonetaDidChangeValue(barcelonetaView, value: 0)
    }

    // MARK: - BarcelonetaDelegate
    func barcelonetaDidStartMoving(_ view: Barceloneta) {}

    func barcelonetaDidChangeValue(_ view: Barceloneta, value: Double) {
        valueLabel.text = "\(Int(value))"
    }

    func barcelonetaDidRelease(_ view: Barceloneta) {
        //the user released la barceloneta
        //Resset to default color
        animateBarcelonetaBackgroundColor(color(forMinimalRange: 0))
    }

    func barcelonetaDidReachNewTimerSetting(_ view: Barceloneta, setting: TimerSetting) {
        animateBarcelonetaBackgroundColor(color(forMinimalRange: setting.range.startIndex))
    }

    ///Color for a minimal range
    fileprivate func color(forMinimalRange range: Int) -> UIColor {
        switch range {
        case 70:
            //Orange
            return UIColor(red: 1.00, green: 0.66, blue: 0.16, alpha: 1.00)
        case 120:
            //Red
            return UIColor(red: 0.90, green: 0.31, blue: 0.26, alpha: 1.00)
        default:
            //Green
            return UIColor(red: 0.22, green: 0.80, blue: 0.46, alpha: 1.00)
        }
    }

    fileprivate func animateBarcelonetaBackgroundColor(_ color: UIColor) {
        self.barcelonetaView.backgroundColor = .clear
        UIView.animate(withDuration: 0.3, animations: {
            self.barcelonetaView.backgroundColor = color
            }, completion: nil)
    }

    // MARK: - Settings
    @IBAction func changedAxis(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            enable(withAxis: .horizontal)
        } else {
            enable(withAxis: .vertical)
        }
    }
    @IBAction func changedLooping(_ sender: UISwitch) {
        barcelonetaView.loops = sender.isOn
    }

    private func enable(withAxis axis: Axis) {
        barcelonetaView.makeElastic(withConstraint:
            axis == .horizontal ? bcnViewHorizontalConstraint : bcnViewVerticalConstraint,
                                    onAxis: axis,
                                    andDelegate: self)
        infoLabel.text = "Drag this view \n\(axis == .vertical ? "⇡ or ⇣" : "⇠ or ⇢")\nto change the value"
    }

    // MARK: -
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
