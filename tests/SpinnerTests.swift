/*
 * SpinnerTests.swift 
 * tests 
 *
 * Created by Callum McColl on 24/09/2016.
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

internal struct SimpleGlobals: GlobalVariables {

    let one: Bool

    let two: UInt8

    let three: Bool

    init() {
        self.one = false
        self.two = 0
        self.three = false
    }

    init(fromDictionary dictionary: [String: Any]) {
        self.one = dictionary["one"]! as! Bool
        self.two = dictionary["two"]! as! UInt8
        self.three = dictionary["three"]! as! Bool
    }

}

func ==(lhs: SimpleGlobals, rhs: SimpleGlobals) -> Bool {
    return lhs.one == rhs.one &&
        lhs.two == rhs.two &&
        lhs.three == rhs.three
}

internal class SimpleContainer<GV: GlobalVariables>: GlobalVariablesContainer, Snapshotable {
    
    typealias Class = GV

    public var val: GV

    public init(val: GV) {
        self.val = val
    }

    func saveSnapshot() {}

    func takeSnapshot() {}

}

class SpinnerTests: XCTestCase {

    static var allTests: [(String, (SpinnerTests) -> () throws -> Void)] {
        return [
            ("test_print", test_print)
        ]
    }
    
    private var container: SimpleContainer<SimpleGlobals>!
    private var generator: TeleportingTurtleScheduleableFSMKripkeStructureGenerator<MirrorPropertyExtractor>!
    private var fsm: FiniteStateMachine<MiPalRinglet<SimpleContainer<SimpleGlobals>>>!

    override func setUp() {
        self.container = SimpleContainer(val: SimpleGlobals())
        self.generator = TeleportingTurtleScheduleableFSMKripkeStructureGenerator(
            extractor: MirrorPropertyExtractor()
        )
        let state = CallbackMiPalState("test", onEntry: { print("onEntry") })
        let ringlet = MiPalRinglet(globals: self.container)
        self.fsm = FiniteStateMachine(
            "test_fsm",
            initialState: state,
            ringlet: ringlet,
            initialPreviousState: EmptyMiPalState("_previous"),
            suspendedState: EmptyMiPalState("_suspendedState"),
            suspendState: EmptyMiPalState("_suspend"),
            exitState: EmptyMiPalState("_exit")
        )
    }

    func test_print() {
        let _ = self.generator.generate(fsm: self.fsm, globals: self.container)
    }

}
