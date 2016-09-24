/*
 * TeleportingTurtleScheduleableFSMKripkeStructureGenerator.swift 
 * FSM 
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

public class TeleportingTurtleScheduleableFSMKripkeStructureGenerator<
    GE: GlobalPropertyExtractor
>: ScheduleableFSMKripkeStructureGenerator {

    private let extractor: GE

    public init(extractor: GE) {
        self.extractor = extractor
    }

    public func generate<
        FSM: FiniteStateMachineType,
        GC: GlobalVariablesContainer
    >(fsm: FSM, globals: GC) -> KripkeStructure where
        FSM: StateExecuter,
        FSM: Finishable
    {
        var finished: Bool = false
        let spinnerData = self.makeSpinnerData(globals: globals)
        while (false == finished) {
            //let state = fsm.currentState
            let spinner: () -> GC.Class? = self.makeSpinner(
                defaultValues: spinnerData.0,
                spinners: spinnerData.1
            )
            // Spin the globals.
            while let gs = spinner() {
                globals.val = gs
                print(gs)
            }
            finished = true
        }
        // Generate a Kripke State.
        // Detect Cycle.
        return KripkeStructure(states: [])
    }

    private func makeSpinnerData<
        GC: GlobalVariablesContainer
    >(globals: GC) -> ([String: Any], [String: (Any) -> Any?]) {
        // Get Global Properties Info
        let temp: [(String, (Any, (Any) -> Any?))] = self.extractor.extract(
                globals: globals.val
            ).map {
                ($0.0, self.makeSpinner(from: $0.1))
            }
        let defaultValues: [String: Any] = temp.map {
                ($0.0, $0.1.0)
            }.reduce([:]) {
                var d = $0
                d[$1.0] = $1.1
                return d
            }
        let spinners: [String: (Any) -> Any?] = temp.map {
                ($0.0, $0.1.1)
            }.reduce([:]) {
                var d = $0
                d[$1.0] = $1.1
                return d
            }
        return (defaultValues, spinners)
    }

    private func makeSpinner<GV: GlobalVariables>(
        defaultValues: [String: Any],
        spinners: [String: (Any) -> Any?]
    ) -> () -> GV? {
        var latest: [String: Any]? = defaultValues
        return { () -> GV? in
            guard let temp = latest else {
                return nil
            }
            guard let ps = self.spin(
                      vars: Array(temp),
                      defaultValues: defaultValues,
                      spinners: spinners
                  )
            else {
                latest = nil
                return GV(fromDictionary: temp)
            }
            latest = ps.reduce([:]) { (d: [String: Any], kv: (String, Any)) -> [String: Any] in
                var d = d
                d[kv.0] = kv.1
                return d
            }
            return GV(fromDictionary: temp)
        }
    }

    private func spin(
        index: Int = 0,
        vars: [(String, Any)],
        defaultValues: [String: Any],
        spinners: [String: (Any) -> Any?]
    ) -> [(String, Any)]? {
        if index >= vars.count {
            return nil
        }
        var vars = vars
        let name: String = vars[index].0
        let currentValue = vars[index].1
        guard let newValue = spinners[name]?(currentValue) else {
            vars[index].1 = defaultValues[name]!
            return self.spin(
                index: index + 1,
                vars: vars,
                defaultValues: defaultValues,
                spinners: spinners
            )
        }
        vars[index].1 = newValue
        return vars
    }

    private func makeSpinner(
        from ksp: KripkeStateProperty
    ) -> (Any, (Any) -> Any?) {
        // These spinners are used more than once
        let uint64Spinner: (Any) -> Any? = {
                let num = $0 as! UInt64
                return num == UInt64.max ? nil : num.advanced(by: 1)
            }
        let uint32Spinner: (Any) -> Any? = {
                let num = $0 as! UInt32
                return num == UInt32.max ? nil : num.advanced(by: 1)
            }
        let uintSpinner: (Any) -> Any? = {
                let num = $0 as! UInt
                return num == UInt.max ? nil : num.advanced(by: 1)
            }
        let floatingPointSignSpinner = {
                let sign = $0 as! FloatingPointSign
                return .plus == sign ? nil : .plus
            }
        switch ksp.type {
        case .Int:
            return (
                Int.min,
                {
                    let num = $0 as! Int
                    return num == Int.max ? nil : num.advanced(by: 1)
                }
            )
        case .Int8:
            return (
                Int8.min,
                {
                    let num = $0 as! Int8
                    return num == Int8.max ? nil : num.advanced(by: 1)
                }
            )
        case .Int16:
            return (
                Int16.min,
                {
                    let num = $0 as! Int16
                    return num == Int16.max ? nil : num.advanced(by: 1)
                }
            )
        case .Int32:
            return (
                Int32.min,
                {
                    let num = $0 as! Int32
                    return num == Int32.max ? nil : num.advanced(by: 1)
                }
            )
        case .Int64:
            return (
                Int64.min,
                {
                    let num = $0 as! Int64
                    return num == Int64.max ? nil : num.advanced(by: 1)
                }
            )
        case .UInt:
            return (UInt.min, uintSpinner)
        case .UInt8:
            return (
                UInt8.min,
                {
                    let num = $0 as! UInt8
                    return num == UInt8.max ? nil : num.advanced(by: 1)
                }
            )
        case .UInt16:
            return (
                UInt16.min,
                {
                    let num = $0 as! UInt16
                    return num == UInt16.max ? nil : num.advanced(by: 1)
                }
            )
        case .UInt32:
            return (UInt32.min, uint32Spinner)
        case .UInt64:
            return (UInt64.min, uint64Spinner)
        case .Float:
            return (
                Float(bitPattern: UInt32.min),
                {
                    let num = $0 as! Float
                    if (num == Float.infinity) {
                        return Float.infinity.negated()
                    }
                    if (num == Float.infinity.negated()) {
                        return Float.nan
                    }
                    if (num == Float.nan) {
                        return nil
                    }
                    if (num.bitPattern == UInt32.max) {
                        return Float.infinity
                    }
                    return Float(bitPattern: num.bitPattern.advanced(by: 1))
                }
            )
