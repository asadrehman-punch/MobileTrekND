//
//  MarsBacManager.swift
//  MobileTrek
//
//  Created by Steven Fisher on 10/24/17.
//  Copyright © 2017 RecoveryTrek. All rights reserved.
//

import UIKit
import CoreBluetooth

final class MarsBacManager: NSObject {
	private var bluetoothManager: CBCentralManager!
	fileprivate var delegate: MarsBacManagerDelegate?
	fileprivate var mainChar: CBCharacteristic?
	fileprivate var breathalyzerDevice: CBPeripheral!
	
	fileprivate let mainServiceUUID = CBUUID(string: "0000ffe0-0000-1000-8000-00805f9b34fb")
	fileprivate let mainCharUUID = CBUUID(string: "0000ffe1-0000-1000-8000-00805f9b34fb")
	
	fileprivate let kCmdConnectDevice = "684230303009026804030004FF01B816"
	private let kCmdStartTest = "684230303009026801020002904216"
	private let kCmdDisconnect = "684230303009026804030004FF00B716"
	private let kCmdBlowNow = "6842303030090268810300029000c316"
	private let kCmdBlowTick = "6842303030090268810300029001c416"
	private let kCmdAnalyze = "6842303030090268810300029002c516"
	private let kCmdAnalyzeAlt = "30090268810300029002c516"
	private let kCmdInterrupt = "6842303030090268810300029003c616"
	private let kCmdResults = "68423030300902688104000390"
	
	private var currentCmd: String? = nil
	fileprivate var deviceStatus: DeviceConnStatus = .disconnected
	
	init(delegate: MarsBacManagerDelegate) {
		super.init()
		
		self.delegate = delegate
		
		bluetoothManager = CBCentralManager(delegate: self, queue: nil)
	}
	
	func connectToNearestDevice() {
		if deviceStatus != .connected {
			sendCommand(value: kCmdConnectDevice)
		}
	}
	
	func disconnectDevice() {
		sendCommand(value: kCmdDisconnect)
	}
	
	func startTest() {
		sendCommand(value: kCmdStartTest)
	}
	
	fileprivate func searchForBreathalyzer() {
		bluetoothManager.scanForPeripherals(withServices: [mainServiceUUID], options: nil)
	}
	
	fileprivate func dataWithHexString(hex: String) -> Data {
		var hex = hex
		var data = Data()
		while(hex.count > 0) {
			let c = String(hex.prefix(2))
			hex = String(hex.dropFirst(2))
			var ch: UInt32 = 0
			Scanner(string: c).scanHexInt32(&ch)
			var char = UInt8(ch)
			data.append(&char, count: 1)
		}
		return data
	}
	
	fileprivate func sendCommand(value: String) {
		if let mc = mainChar {
			print("send = \(value)")
			currentCmd = value
			let data = dataWithHexString(hex: value)
			
			breathalyzerDevice.writeValue(data, for: mc, type: .withoutResponse)
		}
	}
	
	fileprivate func routeCommand(value: String) {
		print("currentCmd = \(currentCmd ?? "NIL COMMAND!")")
		
		if let cmd = currentCmd {
			print("routing cmd = \(cmd) withValue = \(value)")
			
			switch cmd {
			case kCmdConnectDevice:
				if value == "68423030300902688400003116" && deviceStatus == .connecting {
					delegate?.deviceConnected()
					currentCmd = nil
					
					deviceStatus = .connected
					
					startTest()
				}
				
			case kCmdDisconnect:
				if value == "68423030300902688400003116" {
					delegate?.deviceDisconnected()
					currentCmd = nil
					
					deviceStatus = .disconnected
					
					breathalyzerDevice.setNotifyValue(false, for: mainChar!)
					bluetoothManager.cancelPeripheralConnection(breathalyzerDevice)
					bluetoothManager = nil
				}
				
			case kCmdStartTest:
				if value == kCmdBlowNow {
					delegate?.blow()
				}
				else if value == kCmdBlowTick {
					delegate?.blowTick()
				}
				else if value == kCmdAnalyze || value == kCmdAnalyzeAlt {
					delegate?.analyzingData()
				}
				else if value == kCmdInterrupt {
					delegate?.blowError()
					
					self.disconnectDevice()
				}
				else if value.prefix(26) == kCmdResults {
					var bacResults = String(value.dropFirst(26))
					bacResults = String(bacResults.dropLast(4))
					
					print("remaining = \(bacResults)")
					
					let lowVal = Float(Int(String(bacResults.prefix(2)), radix: 16)!)
					let hiVal = Float(Int(String(bacResults.suffix(2)), radix: 16)!)
					
					print("lowVal = \(lowVal)")
					print("hiVal = \(hiVal)")
					
					let actualResult = ((hiVal * 256) + lowVal) * 0.001
					
					currentCmd = nil
					
					delegate?.results(bac: actualResult)
				}
				
			default:
				print("Unknown value = \(value)")
			}
		}
	}
}

protocol MarsBacManagerDelegate {
	func deviceConnected()
	func deviceDisconnected()
	func blow()
	func blowTick()
	func analyzingData()
	func results(bac: Float)
	func blowError()
    func bluetoothConnected()
    func bluetoothDisconnected()
}

fileprivate enum DeviceConnStatus {
	case connected
	case connecting
	case disconnected
}

extension MarsBacManager: CBCentralManagerDelegate {
	func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
		breathalyzerDevice.delegate = self
		breathalyzerDevice.discoverServices([mainServiceUUID])
	}
	
	func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
		delegate?.deviceDisconnected()
	}
	
	func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
		
	}
	
	func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
		print("Found Device")
		
		if let deviceName = peripheral.name, deviceName == "HMSoft", deviceStatus != .connecting {
			deviceStatus = .connecting
			central.stopScan()
			
			breathalyzerDevice = peripheral
			central.connect(breathalyzerDevice, options: nil)
		}
	}
	
	func centralManagerDidUpdateState(_ central: CBCentralManager) {
		switch central.state {
		case .poweredOn:
            delegate?.bluetoothConnected()
            searchForBreathalyzer()
            
        case .poweredOff:
            delegate?.bluetoothDisconnected()
            
		default:
			print("state = \(central.state.rawValue)")
		}
	}
}

extension MarsBacManager: CBPeripheralDelegate {
	func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
		if let mainService = breathalyzerDevice.services?.first {
			breathalyzerDevice.discoverCharacteristics([mainCharUUID], for: mainService)
		}
	}
	
	func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
		if let c = service.characteristics?.first {
			self.mainChar = c
			breathalyzerDevice.setNotifyValue(true, for: mainChar!)
			
			connectToNearestDevice()
		}
	}
	
	func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
		if let val = characteristic.value {
			let response = val.map { String(format: "%02x", $0) }.joined()
			
			print("response = \(response)")
			
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
				self.routeCommand(value: response)
			})
		}
	}
}

