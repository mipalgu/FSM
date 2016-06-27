/*
 * BehaviourTests.swift 
 * tests 
 *
 * Created by Callum McColl on 12/03/2016.
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

class BehaviourTests: XCTestCase {

    static var allTests: [(String, (BehaviourTests) -> () throws -> Void)] {
        return [
            ("test_always", test_always),
            ("test_singleMap", test_singleMap),
            ("test_multipleMap", test_multipleMap),
            ("test_addition", test_addition),
            ("test_subtraction", test_subtraction),
            ("test_multiplication", test_multiplication),
            ("test_division", test_division),
            ("test_mod", test_mod),
            ("test_lessThan", test_lessThan),
            ("test_lessThanOrEqualTo", test_lessThanOrEqualTo),
            ("test_greaterThan", test_greaterThan),
            ("test_greaterThanOrEqualTo", test_greaterThanOrEqualTo),
            ("test_equals", test_equals),
            ("test_notEquals", test_notEquals),
            ("test_trigger", test_trigger),
            ("test_triggerWithRemember", test_triggerWithRemember)
        ]
    }

    func test_always() {
        let b: Behaviour<Int> = always(4)
        XCTAssertEqual(4, b.at(1))
    }

    func test_singleMap() {
        let b: Behaviour<Int> = always(4)
        let m: Behaviour<Int> = { $0 * 2 } <^> b
        XCTAssertEqual(8, m.at(1))
    }

    func test_multipleMap() {
        let f: ([Int]) -> Int = { $0.reduce(0, combine: +) }
        let m: Behaviour<Int> = f <^> [always(1), always(2), always(3), always(4)]
        XCTAssertEqual(10, m.at(1))
    }

    func test_addition() {
        let b: Behaviour<Int> = always(3) + always(2)
        XCTAssertEqual(5, b.at(1))
    }

    func test_subtraction() {
        let b: Behaviour<Int> = always(3) - always(2)
        XCTAssertEqual(1, b.at(1))
    }

    func test_multiplication() {
        let b: Behaviour<Int> = always(3) * always(2)
        XCTAssertEqual(6, b.at(1))
    }

    func test_division() {
        let b: Behaviour<Int> = always(6) / always(2)
        XCTAssertEqual(3, b.at(1))
    }

    func test_mod() {
        let b: Behaviour<Int> = always(6) % always(2)
        XCTAssertEqual(0, b.at(1))
    }

    func test_lessThan() {
        let b: Behaviour<Bool> = always(3) < always(2)
        XCTAssertFalse(b.at(1))
        let b2: Behaviour<Bool> = always(2) < always(3)
        XCTAssertTrue(b2.at(1))
    }

    func test_lessThanOrEqualTo() {
        let b: Behaviour<Bool> = always(3) <= always(2)
        XCTAssertFalse(b.at(1))
        let b2: Behaviour<Bool> = always(2) <= always(3)
        XCTAssertTrue(b2.at(1))
    }

    func test_greaterThan() {
        let b: Behaviour<Bool> = always(3) > always(2)
        XCTAssertTrue(b.at(1))
        let b2: Behaviour<Bool> = always(2) > always(3)
        XCTAssertFalse(b2.at(1))
    }

    func test_greaterThanOrEqualTo() {
        let b: Behaviour<Bool> = always(3) >= always(2)
        XCTAssertTrue(b.at(1))
        let b2: Behaviour<Bool> = always(2) >= always(3)
        XCTAssertFalse(b2.at(1))
    }

    func test_equals() {
        let b: Behaviour<Bool> = always(3) == always(3)
        XCTAssertTrue(b.at(1))
        let b2: Behaviour<Bool> = always(4) == always(3)
        XCTAssertFalse(b2.at(1))
    }

    func test_notEquals() {
        let b: Behaviour<Bool> = always(3) != always(3)
        XCTAssertFalse(b.at(1))
        let b2: Behaviour<Bool> = always(4) != always(3) 
        XCTAssertTrue(b2.at(1))
    }

    func test_trigger() {
        let t: (b: Behaviour<Int?>, m: (Int) -> ()) = trigger()
        XCTAssertNil(t.b.at(0))
        t.m(5)
        t.m(6)
        XCTAssertEqual(5, t.b.at(0))
        XCTAssertEqual(6, t.b.at(1))
    }

    func test_triggerWithRemember() {
        let t: (b: Behaviour<Int?>, m: (Int) -> ()) = trigger(remember: 3)
        XCTAssertNil(t.b.at(0))
        t.m(5)
        t.m(6)
        t.m(7)
        XCTAssertEqual(5, t.b.at(0))
        XCTAssertEqual(6, t.b.at(1))
        XCTAssertEqual(7, t.b.at(2))
        t.m(8)
        XCTAssertNil(t.b.at(0))
        XCTAssertEqual(8, t.b.at(3))
    }

}
