/*
 * GenericWhiteboardTests.swift 
 * tests 
 *
 * Created by Callum McColl on 19/03/2016.
 * Copyright © 2016 Callum McColl. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above
 *    copyright notice, this list of conditions and the following
 *    disclaimer in the documentation and/or other materials
 *    provided with the distribution.
 *
 * 3. All advertising materials mentioning features or use of this
 *    software must display the following acknowledgement:
 *
 *        This product includes software developed by Callum McColl.
 *
 * 4. Neither the name of the author nor the names of contributors
 *    may be used to endorse or promote products derived from this
 *    software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER
 * OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 * -----------------------------------------------------------------------
 * This program is free software; you can redistribute it and/or
 * modify it under the above terms or under the terms of the GNU
 * General Public License as published by the Free Software Foundation;
 * either version 2 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, see http://www.gnu.org/licenses/
 * or write to the Free Software Foundation, Inc., 51 Franklin Street,
 * Fifth Floor, Boston, MA  02110-1301, USA.
 *
 */

import XCTest
@testable import FSM

public class GenericWhiteboardTests: XCTestCase {

    public static var allTests: [(String, (GenericWhiteboardTests) -> () throws -> Void)] {
        return [
            ("test_changeIndex", test_changeIndex),
            ("test_changeIndexWithOverflow", test_changeIndexWithOverflow),
            ("test_postStoresValue", test_postStoresValue),
            ("test_postIncrementsIndex", test_postIncrementsIndex),
            ("test_postIncrementsEventCount", test_postIncrementsEventCount),
            ("test_messagesStoresTheMessage", test_messagesStoresTheMessage),
            ("test_changeMessages", test_changeMessages),
            ("test_iteration", test_iteration)
        ]
    }

    private var wb: Whiteboard = Whiteboard()
    private var gwb: GenericWhiteboard<wb_count>! 

    public override func setUp() {
        self.gwb = GenericWhiteboard<wb_count>(msgType: kCount_v, wb: self.wb)
        for _ in 0 ..< gwb.generations {
            self.wb.post(val: wb_count(), msg: kCount_v)
        }
        self.gwb.eventCount = 0
        self.gwb.currentIndex = 0
    }

    public func test_changeIndex() {
        let i: UInt8 = gwb.currentIndex
        if (0 == i) {
            gwb.currentIndex = 1
            XCTAssertEqual(gwb.currentIndex, 1)
            return
        }
        gwb.currentIndex = 0
        XCTAssertEqual(gwb.currentIndex, 0)
    }

    public func test_changeIndexWithOverflow() {
        let i: UInt8 = UInt8(gwb.generations)
        gwb.currentIndex = i
        XCTAssertEqual(gwb.currentIndex, 0)
    }

    public func test_postStoresValue() {
        gwb.post(val: wb_count(count: 7))
        XCTAssertEqual(gwb.currentMessage.count, 7)
    }

    public func test_postIncrementsIndex() {
        let i: UInt8 = gwb.currentIndex
        gwb.post(val: wb_count(count: 7))
        let j = i + 1
        XCTAssertEqual(gwb.currentIndex, j)
    }

    public func test_postIncrementsEventCount() {
        let e: UInt16 = gwb.eventCount
        gwb.post(val: wb_count(count: 8))
        let j = e + 1
        XCTAssertEqual(gwb.eventCount, j)
    }

    public func test_messagesStoresTheMessage() {
        let _: ConvertibleCArray<gu_simple_message, wb_count> = gwb.messages
        let msg: wb_count = wb_count(count: 9)
        gwb.post(val: msg)
        let _: ConvertibleCArray<gu_simple_message, wb_count> = gwb.messages
        XCTAssertEqual(gwb.messages[Int(gwb.currentIndex)], msg)
    }

    public func test_changeMessages() {
        var m: ConvertibleCArray<gu_simple_message, wb_count> = gwb.messages
        let msg: wb_count = wb_count(count: 10)
        m[2] = msg
        let m2: ConvertibleCArray<gu_simple_message, wb_count> = gwb.messages
        XCTAssertEqual(msg, m2[2])
        XCTAssertEqual(m[2], m2[2])
    }

    public func test_iteration() {
        XCTAssertEqual(gwb.orderedMessages.count, gwb.generations)
        for i in 0 ..< gwb.generations {
            self.gwb.post(val: wb_count(count: Int64(i)))
        }
        var i: Int = gwb.generations - 1
        for count: wb_count in gwb {
            XCTAssertEqual(count, wb_count(count: Int64(i)))
            i = i - 1
        }
        XCTAssertEqual(gwb.orderedMessages, [3, 2, 1, 0].map({wb_count(count: $0)}))
    }

}
