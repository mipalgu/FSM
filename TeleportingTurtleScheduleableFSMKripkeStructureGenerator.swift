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

    private let spinners: Spinners

    public init(extractor: GE, spinners: Spinners = Spinners()) {
        self.extractor = extractor
        self.spinners = spinners
    }

    public func generate<
        FSM: FiniteStateMachineType,
        GC: GlobalVariablesContainer
    >(fsm: FSM, globals: GC) -> KripkeStructure where
        FSM: StateExecuter,
        FSM: Finishable,
        FSM._StateType: Cloneable
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
            guard let vs = self.spin(
                      index: temp.startIndex,
                      vars: temp,
                      defaultValues: defaultValues,
                      spinners: spinners
                  )
            else {
                latest = nil
                return GV(fromDictionary: temp)
            }
            latest = vs
            return GV(fromDictionary: temp)
        }
    }

    private func spin(
        index: DictionaryIndex<String, Any>,
        vars: [String: Any],
        defaultValues: [String: Any],
        spinners: [String: (Any) -> Any?]
    ) -> [String: Any]? {
        if (index == vars.endIndex) {
            return nil
        }
        var vars = vars
        let name: String = vars[index].key
        let currentValue = vars[index].value
        guard let newValue = spinners[name]?(currentValue) else {
            vars[vars[index].key] = defaultValues[name]!
            return self.spin(
                index: vars.index(after: index),
                vars: vars,
                defaultValues: defaultValues,
                spinners: spinners
            )
        }
        vars[vars[index].key] = newValue
        return vars
    }

    private func makeSpinner(
        from ksp: KripkeStateProperty
    ) -> (Any, (Any) -> Any?) {
        switch ksp.type {
        case .Int:
            return (Int.min, { self.spinners.int($0 as! Int) })
        case .Int8:
            return (Int8.min, { self.spinners.int8($0 as! Int8) })
        case .Int16:
            return (Int16.min, { self.spinners.int16($0 as! Int16) })
        case .Int32:
            return (Int32.min, { self.spinners.int32($0 as! Int32) })
        case .Int64:
            return (Int64.min, { self.spinners.int64($0 as! Int64) })
        case .UInt:
            return (UInt.min, { self.spinners.uint($0 as! UInt) })
        case .UInt8:
            return (UInt8.min, { self.spinners.uint8($0 as! UInt8) })
        case .UInt16:
            return (UInt16.min, { self.spinners.uint16($0 as! UInt16) })
        case .UInt32:
            return (UInt32.min, { self.spinners.uint32($0 as! UInt32) })
        case .UInt64:
            return (UInt64.min, { self.spinners.uint64($0 as! UInt64) })
        case .Float:
            return (Float.infinity.negated(), { self.spinners.float($0 as! Float) })
        case .Float80:
            return (Float80.infinity.negated(), { self.spinners.float80($0 as! Float80) })
        case .Double:
            return (Double.infinity.negated(), { self.spinners.double($0 as! Double) })
        default:
            return (ksp.value, self.spinners.nilSpinner) 
        }
    }

}
