/*
 * FactoriesTest.swift 
 * tests 
 *
 * Created by Callum McColl on 16/04/2016.
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

class FactoriesTests: XCTestCase {

    static var allTests: [(String, (FactoriesTests) -> () throws -> Void)] {
        return [
            ("test_count", test_count),
            ("test_isEmptyWhenEmpty", test_isEmptyWhenEmpty),
            ("test_isEmptyWhenNotEmpty", test_isEmptyWhenNotEmpty),
            ("test_isMonostate", test_isMonostate),
            ("test_peek", test_peek),
            ("test_pop", test_pop)
        ]
    }

    override func setUp() {
        var f: Factories = Factories()
        f.clear()
    }

    func test_count() {
        var f: Factories = Factories()
        XCTAssertEqual(f.count, 0)
        f.push({[]})
        f.push({[]})
        XCTAssertEqual(f.count, 2)
    }

    func test_isEmptyWhenEmpty() {
        let f: Factories = Factories()
        XCTAssert(f.isEmpty)
    }

    func test_isEmptyWhenNotEmpty() {
        var f: Factories = Factories()
        f.push({[]})
        XCTAssertFalse(f.isEmpty)
    }

    func test_isMonostate() {
        var f1: Factories = Factories()
        let f2: Factories = Factories()
        let count: Int = f1.count
        XCTAssertEqual(f1.count, f2.count)
        f1.push({ [] })
        XCTAssertEqual(f1.count, f2.count)
        XCTAssertEqual(f1.count, count + 1)
    }

    func test_peek() {
        var f: Factories = Factories()
        let fact: () -> [AnyScheduleableFiniteStateMachine] = {
            [FSM("test", initialState: EmptyState("initial"))]
        }
        f.push({[]})
        f.push(fact)
        XCTAssertEqual(f.count, 2)
        XCTAssertEqual(fact()[0].name, f.peek()!()[0].name)
        XCTAssertEqual(f.count, 2)
    }

    func test_pop() {
        var f: Factories = Factories()
        f.push({[]})
        f.push({[]})
        XCTAssertEqual(f.count, 2)
        let _ = f.pop()
        XCTAssertEqual(f.count, 1)
        let _ = f.pop()
        XCTAssertEqual(f.count, 0)
    }

}
