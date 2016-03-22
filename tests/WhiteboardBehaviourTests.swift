/*
 * WhiteboardBehaviourTests.swift 
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

#if os(OSX)
import Darwin
#elseif os(Linux)
import Glibc
#endif

class WhiteboardBehaviourTests: XCTestCase {

    var allTests: [(String, () throws -> Void)] {
        return [
            ("test_trigger", test_trigger)
        ]
    }

    func setUp() {
        print("setup")
        let wb: Whiteboard = Whiteboard()
        wb.post(wb_count(), msg: kCount_v)
        wb.post(wb_count(), msg: kCount_v)
        wb.post(wb_count(), msg: kCount_v)
        wb.post(wb_count(), msg: kCount_v)
    }

    func test_trigger() {
        //let b: (Behaviour<wb_count?>, Int) = f(1)
        let t: (b: Behaviour<wb_count?>, f: (wb_count) -> Void) =
            trigger(kCount_v)
        t.f(pure(1))
        t.f(pure(2))
        t.f(pure(3))
        t.f(pure(4))
        XCTAssertEqual(t.b.f(0), pure(1))
        XCTAssertEqual(t.b.f(1), pure(2))
        XCTAssertEqual(t.b.f(2), pure(3))
        XCTAssertEqual(t.b.f(3), pure(4))
    }

    /*private func f<T: GlobalVariables>(type: Int) -> (Behaviour<T?>, Int) {
        return (Behaviour { (t: Time) -> T? in nil }, 0)
    }*/

}