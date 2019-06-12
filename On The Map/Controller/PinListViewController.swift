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
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!

	lazy var refreshControl: UIRefreshControl = {
		let refreshControl = UIRefreshControl()
		refreshControl.tintColor = .black
		refreshControl.addTarget(self, action: #selector(refreshStudentPinList), for: .valueChanged)

		return refreshControl
	}()

	var currentRecordNumber: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()

		self.tableView.dataSource = self
		self.tableView.delegate = self

		tableView.refreshControl = refreshControl
    }

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

		refreshStudentPinList()

		currentRecordNumber = StudentLocations.locations.count

		tableView.reloadData()
	}

	@objc func refreshStudentPinList() {
		isDownloading(true)

		StudentLocations.refreshStudentLocations { [unowned self] (error) in
			guard error == nil else { return }

			self.currentRecordNumber = StudentLocations.locations.count

			DispatchQueue.main.async {
				self.tableView.reloadData()
				self.isDownloading(false)
			}

			let deadline = DispatchTime.now() + .milliseconds(500)
			DispatchQueue.main.asyncAfter(deadline: deadline, execute: {
				self.refreshControl.endRefreshing()
			})
		}
	}

	@IBAction func addPinButtonTapped(_ sender: Any) {
		activityIndicator.startAnimating()
		UdacityClient.getStudentLocation(allStudents: false) { [unowned self] (response, error) in

			response.count > 0 ? self.presentOverwriteAlert(students: response) : self.performSegue(withIdentifier: "addPin", sender: (false, []))

			self.activityIndicator.stopAnimating()
		}
	}

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "addPin" {
			let destinationVC = segue.destination as? AddPinViewController
			let updateStudentInfo = sender as? (Bool, [StudentLocation])
			destinationVC?.updatePin = updateStudentInfo?.0
			destinationVC?.studentLocations = updateStudentInfo?.1
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
		let app = UIApplication.shared
		app.open(URL(string: StudentLocations.locations[indexPath.row].mediaURL) ?? URL(string: "")!, options: [:], completionHandler: nil)
	}

	func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		guard currentRecordNumber > 0 else { return }
		guard indexPath.row == StudentLocations.locations.count-1 else { return }
		guard StudentLocations.locations.count % 100 == 0 else { return }

		StudentLocations.getMoreStudentLocations(startingRecord: indexPath.row) { [unowned self] (error) in
			guard error == nil else { return }

			self.currentRecordNumber += StudentLocations.locations.count

			DispatchQueue.main.async {
				self.tableView.reloadData()
			}
		}
	}
}


