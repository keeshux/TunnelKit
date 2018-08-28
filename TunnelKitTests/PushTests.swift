//
//  PushTests.swift
//  TunnelKitTests
//
//  Created by Davide De Rosa on 8/24/18.
//  Copyright (c) 2018 Davide De Rosa. All rights reserved.
//
//  https://github.com/keeshux
//
//  This file is part of TunnelKit.
//
//  TunnelKit is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  TunnelKit is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with TunnelKit.  If not, see <http://www.gnu.org/licenses/>.
//

import XCTest
@testable import TunnelKit

private extension SessionReply {
    func debug() {
        print("Address: \(address)")
        print("Mask: \(addressMask)")
        print("Gateway: \(defaultGateway)")
        print("DNS: \(dnsServers)")
    }
}

class PushTests: XCTestCase {
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testNet30() {
        let msg = "PUSH_REPLY,redirect-gateway def1,dhcp-option DNS 209.222.18.222,dhcp-option DNS 209.222.18.218,ping 10,comp-lzo no,route 10.5.10.1,topology net30,ifconfig 10.5.10.6 10.5.10.5,auth-token AUkQf/b3nj3L+CH4RJPP0Vuq8/gpntr7uPqzjQhncig="
        let reply = try! SessionProxy.PushReply(message: msg)!
        reply.debug()

        XCTAssertEqual(reply.address, "10.5.10.6")
        XCTAssertEqual(reply.addressMask, "255.255.255.255")
        XCTAssertEqual(reply.defaultGateway, "10.5.10.5")
        XCTAssertEqual(reply.dnsServers, ["209.222.18.222", "209.222.18.218"])
    }
    
    func testSubnet() {
        let msg = "PUSH_REPLY,dhcp-option DNS 8.8.8.8,dhcp-option DNS 4.4.4.4,route-gateway 10.8.0.1,topology subnet,ping 10,ping-restart 120,ifconfig 10.8.0.2 255.255.255.0,peer-id 0"
        let reply = try! SessionProxy.PushReply(message: msg)!
        reply.debug()
        
        XCTAssertEqual(reply.address, "10.8.0.2")
        XCTAssertEqual(reply.addressMask, "255.255.255.0")
        XCTAssertEqual(reply.defaultGateway, "10.8.0.1")
        XCTAssertEqual(reply.dnsServers, ["8.8.8.8", "4.4.4.4"])
    }
    
    func testRoute() {
        let msg = "PUSH_REPLY,dhcp-option DNS 8.8.8.8,dhcp-option DNS 4.4.4.4,route-gateway 10.8.0.1,route 192.168.0.0 255.255.255.0 10.8.0.12,topology subnet,ping 10,ping-restart 120,ifconfig 10.8.0.2 255.255.255.0,peer-id 0"
        let reply = try! SessionProxy.PushReply(message: msg)!
        reply.debug()
        
        let route = reply.routes.first!
        
        XCTAssertEqual(route.destination, "192.168.0.0")
        XCTAssertEqual(route.mask, "255.255.255.0")
        XCTAssertEqual(route.gateway, "10.8.0.12")
    }
}