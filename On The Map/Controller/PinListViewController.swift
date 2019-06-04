//
//  ListViewController.swift
//  On The Map
//
//  Created by Brent Mifsud on 2019-06-02.
//  Copyright © 2019 Brent Mifsud. All rights reserved.
//

import UIKit

class PinListViewController: UIViewController {

	@IBOutlet weak var tableView: UITableView!

	lazy var refreshControl: UIRefreshControl = {
		let refreshControl = UIRefreshControl()
		refreshControl.tintColor = .black
		refreshControl.addTarget(self, action: #selector(refreshStudentPinList), for: .valueChanged)

		return refreshControl
	}()

	var currentRecordNumber: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()

		tableView.refreshControl = refreshControl

		if StudentLocations.locations.count == 0 {
			refreshStudentPinList()
		}

		currentRecordNumber = StudentLocations.locations.count
    }

	override func viewWillAppear(_ animated: Bool) {
		super .viewWillAppear(animated)

		self.tableView.dataSource = self
		self.tableView.delegate = self

		tableView.reloadData()
	}

	@objc func refreshStudentPinList() {
		isDownloading(true)

		StudentLocations.refreshStudentLocations { (error) in
			guard error == nil else { return }
			unowned let pinListVC = self

			pinListVC.currentRecordNumber = StudentLocations.locations.count

			DispatchQueue.main.async {
				pinListVC.tableView.reloadData()
				pinListVC.isDownloading(false)
			}

			let deadline = DispatchTime.now() + .milliseconds(500)
			DispatchQueue.main.asyncAfter(deadline: deadline, execute: {
				pinListVC.refreshControl.endRefreshing()
			})
		}
	}
}

//MARK:- UITableView Methods
extension PinListViewController: UITableViewDelegate, UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return StudentLocations.locations.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "StudentPinCell")!

		let studentPin = StudentLocations.locations[indexPath.row]

		cell.textLabel?.text = studentPin.firstName + " " + studentPin.lastName
		cell.detailTextLabel?.text = studentPin.mediaURL
		cell.imageView?.image = UIImage(named: "icon_pin")

		return cell
	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		//TODO: Open mediaURL in cell
	}

	func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		guard currentRecordNumber > 0 else { return }
		guard indexPath.row == StudentLocations.locations.count-1 else { return }
		guard StudentLocations.locations.count % 100 == 0 else { return }

		StudentLocations.getMoreStudentLocations(startingRecord: indexPath.row) { (error) in
			guard error == nil else { return }

			unowned let pinListVC = self

			pinListVC.currentRecordNumber += StudentLocations.locations.count

			DispatchQueue.main.async {
				pinListVC.tableView.reloadData()
			}
		}
	}
}


