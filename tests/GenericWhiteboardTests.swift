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

    public var allTests: [(String, () throws -> Void)] {
        return [
            ("test_changeIndex", test_changeIndex),
            ("test_changeIndexWithOverflow", test_changeIndexWithOverflow),
            ("test_postStoresValue", test_postStoresValue),
            ("test_postIncrementsIndex", test_postIncrementsIndex)
        ]
    }

    private var wb: GenericWhiteboard<wb_count> = 
        GenericWhiteboard<wb_count>(msgType: kCount_v)

    public func setUp() {
        self.wb = GenericWhiteboard<wb_count>(msgType: kCount_v)
        for _ in 0 ..< wb.generations {
            self.wb.post(wb_count())
        }
        self.wb.eventCount = 0
    }

    public func test_changeIndex() {
        let i: UInt8 = wb.currentIndex
        if (0 == i) {
            wb.currentIndex = 1
            XCTAssertEqual(wb.currentIndex, 1)
            return
        }
        wb.currentIndex = 0
        XCTAssertEqual(wb.currentIndex, 0)
    }

    public func test_changeIndexWithOverflow() {
        let i: UInt8 = UInt8(wb.generations)
        wb.currentIndex = i
        XCTAssertEqual(wb.currentIndex, 0)
    }

    public func test_postStoresValue() {
        wb.post(wb_count(count: 7))
        XCTAssertEqual(wb.currentMessage.count, 7)
    }

    public func test_postIncrementsIndex() {
        let i: UInt8 = wb.currentIndex
        wb.post(wb_count(count: 7))
        XCTAssertEqual(wb.currentIndex, i + 1)
    }

}