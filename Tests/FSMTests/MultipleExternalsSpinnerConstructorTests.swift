/*
 * MultipleExternalsSpinnerConstructorTests.swift
 * FSMTests
 *
 * Created by Callum McColl on 10/9/18.
 * Copyright © 2018 Callum McColl. All rights reserved.
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

@testable import FSMVerification
import FSM
import swiftfsm
import ModelChecking
import ExternalVariables
import KripkeStructure
import CGUSimpleWhiteboard
import GUSimpleWhiteboard

import XCTest

class MultipleExternalsSpinnerConstructorTests: XCTestCase {
    
    static var allTests: [(String, (MultipleExternalsSpinnerConstructorTests) -> () throws -> Void)] {
        return [
            ("test_canSpinMicrowaveVariables", test_canSpinMicrowaveVariables)
        ]
    }
    
    fileprivate var constructor: MultipleExternalsSpinnerConstructor<ExternalsSpinnerConstructor<SpinnerRunner>>!
    fileprivate var extractor: ExternalsSpinnerDataExtractor<MirrorKripkePropertiesRecorder, KripkeStatePropertySpinnerConverter>!
    
    override func setUp() {
        self.constructor = MultipleExternalsSpinnerConstructor(
            constructor: ExternalsSpinnerConstructor(
                runner: SpinnerRunner()
            )
        )
        self.extractor = ExternalsSpinnerDataExtractor(
            converter: KripkeStatePropertySpinnerConverter(),
            extractor: MirrorKripkePropertiesRecorder()
        )
    }
    
    func test_canSpinMicrowaveVariables() {
        let microwave_status = AnySnapshotController(SnapshotCollectionController<GenericWhiteboard<wb_microwave_status>>(
            "kMicrowaveStatus_v",
            collection: GenericWhiteboard<wb_microwave_status>(
                msgType: kMicrowaveStatus_v,
                atomic: false,
                shouldNotifySubscribers: true
            )
        ))
        let spinner = self.makeSpinner([microwave_status])
        let expected: [KripkeStatePropertyList] = [
            KripkeStatePropertyList(["buttonPushed": KripkeStateProperty(type: .Bool, value: false), "doorOpen": KripkeStateProperty(type: .Bool, value: false), "timeLeft": KripkeStateProperty(type: .Bool, value: false)]),
            KripkeStatePropertyList(["buttonPushed": KripkeStateProperty(type: .Bool, value: true), "doorOpen": KripkeStateProperty(type: .Bool, value: false), "timeLeft": KripkeStateProperty(type: .Bool, value: false)]),
            KripkeStatePropertyList(["buttonPushed": KripkeStateProperty(type: .Bool, value: false), "doorOpen": KripkeStateProperty(type: .Bool, value: true), "timeLeft": KripkeStateProperty(type: .Bool, value: false)]),
            KripkeStatePropertyList(["buttonPushed": KripkeStateProperty(type: .Bool, value: true), "doorOpen": KripkeStateProperty(type: .Bool, value: true), "timeLeft": KripkeStateProperty(type: .Bool, value: false)]),
            KripkeStatePropertyList(["buttonPushed": KripkeStateProperty(type: .Bool, value: false), "doorOpen": KripkeStateProperty(type: .Bool, value: false), "timeLeft": KripkeStateProperty(type: .Bool, value: true)]),
            KripkeStatePropertyList(["buttonPushed": KripkeStateProperty(type: .Bool, value: true), "doorOpen": KripkeStateProperty(type: .Bool, value: false), "timeLeft": KripkeStateProperty(type: .Bool, value: true)]),
            KripkeStatePropertyList(["buttonPushed": KripkeStateProperty(type: .Bool, value: false), "doorOpen": KripkeStateProperty(type: .Bool, value: true), "timeLeft": KripkeStateProperty(type: .Bool, value: true)]),
            KripkeStatePropertyList(["buttonPushed": KripkeStateProperty(type: .Bool, value: true), "doorOpen": KripkeStateProperty(type: .Bool, value: true), "timeLeft": KripkeStateProperty(type: .Bool, value: true)])
        ]
        var i: Int = 0
        while let data = spinner() {
            XCTAssertEqual(data.count, 1)
            if data.count != 1 {
                return
            }
            if i >= expected.count {
                XCTFail("Created more data than expected")
                return
            }
            XCTAssertEqual(expected[i], data[0].1)
            i += 1
        }
    }
    
    fileprivate func makeSpinner(_ externalVariables: [AnySnapshotController]) -> () -> [(AnySnapshotController, KripkeStatePropertyList)]? {
        let externals = externalVariables.map { (externals: AnySnapshotController) -> ExternalVariablesVerificationData in
            let (defaultValues, spinners) = self.extractor.extract(externalVariables: externals)
            return ExternalVariablesVerificationData(
                externalVariables: externals,
                defaultValues: defaultValues,
                spinners: spinners
            )
        }
        return self.constructor.makeSpinner(forExternals: externals)
    }
    
}
