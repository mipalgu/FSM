/*
 * NuSMVKripkeStructureView.swift
 * ModelChecking
 *
 * Created by Callum McColl on 15/10/18.
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

import Hashing
import IO
import KripkeStructure
import swift_helpers
import Utilities

#if os(macOS)
import Darwin
#else
import Glibc
#endif

public final class NuSMVKripkeStructureView<State: KripkeStateType>: KripkeStructureView {

    fileprivate let extractor: PropertyExtractor<NuSMVPropertyFormatter>

    fileprivate let identifier: String

    fileprivate let outputStreamFactory: OutputStreamFactory
    
    fileprivate var stream: OutputStream!

    fileprivate var properties: [String: Ref<Set<String>>] = [:]

    fileprivate var states: [KripkeStatePropertyList: State] = [:]
    
    private var acceptingStates: Set<KripkeStatePropertyList> = Set()
    
    private var clocks: Set<String> = Set()
    
    private var usingClocks: Bool = false

    fileprivate var firstState: State?

    fileprivate var initials: Set<[String: String]> = []

    public init(
        identifier: String,
        extractor: PropertyExtractor<NuSMVPropertyFormatter> = PropertyExtractor(formatter: NuSMVPropertyFormatter()),
        outputStreamFactory: OutputStreamFactory = FileOutputStreamFactory()
    ) {
        self.identifier = identifier
        self.extractor = extractor
        self.outputStreamFactory = outputStreamFactory
    }

    public func reset(usingClocks: Bool) {
        self.acceptingStates = Set()
        self.clocks = ["c"]
        self.usingClocks = usingClocks
        self.states = Dictionary(minimumCapacity: 500000)
        self.stream = self.outputStreamFactory.make(id: self.identifier + ".smv")
        self.properties = ["status": Ref(value: Set(["\"executing\"", "\"finished\"", "\"error\""]))]
        self.firstState = nil
        self.initials = []
    }

    public func commit(state: State, isInitial: Bool) {
        if nil == self.firstState {
            self.firstState = state
        }
        if nil != self.states[state.properties] {
            return
        }
        states[state.properties] = state
        if state.edges.count > 0 {
            self.acceptingStates.remove(state.properties)
        }
        state.edges.lazy.compactMap { $0.clockName }.forEach {
            let clockName = self.extractor.convert(label: $0)
            self.clocks.insert(clockName)
        }
        let props = self.extractor.extract(from: state.properties)
        if true == isInitial {
            self.initials.insert(props)
        }
        for (key, value) in props {
            guard let list = self.properties[key] else {
                self.properties[key] = Ref<Set<String>>(value: [value])
                continue
            }
            list.value.insert(value)
        }
    }

    public func finish() {
        defer { self.stream.close() }
        self.stream.flush()
        if self.usingClocks {
            self.stream.write("@TIME_DOMAIN continuous\n\n")
        }
        self.stream.write("MODULE main\n\n")
        var outputStream: TextOutputStream = self.stream
        self.createPropertiesList(usingStream: &outputStream)
        self.createInitial(usingStream: &outputStream)
        self.createTransitions(writingTo: &outputStream)
        self.stream.flush()
    }

    fileprivate func createPropertiesList(usingStream stream: inout TextOutputStream) {
        if self.usingClocks {
            stream.write("VAR sync: real;\n")
            stream.write("INVAR TRUE -> sync >= 0;\n\n")
            stream.write("VAR c: clock;\n")
            stream.write("INVAR TRUE -> c >= 0;\n")
            stream.write("INVAR TRUE -> c <= sync;\n\n")
            self.clocks.lazy.filter { $0 != "c" }.sorted().forEach {
                stream.write("VAR \($0): clock;\n")
                stream.write("INVAR TRUE -> \($0) >= c;\n\n")
            }
        }
        self.properties.sorted { $0.key < $1.key }.forEach {
            let values = $1.value.sorted()
            guard let first = values.first else {
                stream.write("\($0) : {};\n\n")
                return
            }
            stream.write("VAR \($0) : {\n")
            stream.write("    " + first)
            values.dropFirst().forEach {
                stream.write(",\n    " + $0)
            }
            stream.write("\n};\n\n")
        }
    }

    fileprivate func createInitial(usingStream stream: inout TextOutputStream) {
        if self.initials.isEmpty {
            stream.write("INIT();\n")
            return
        }
        let allClocks = self.usingClocks ? self.clocks.sorted() : []
        stream.write("INIT\n")
        let initials = self.initials.lazy.map {
            var props = $0
            if self.usingClocks {
                props["sync"] = "0"
                allClocks.forEach {
                    props[$0] = "0"
                }
            }
            props["status"] = "\"executing\""
            return "(" + self.createConditions(of: props) + ")"
        }.sorted().combine("") { $0 + " | " + $1 }
        stream.write(initials + ";")
        stream.write("\n\n")
    }

    fileprivate func createTransitions(
        writingTo outputStream: inout TextOutputStream
    ) {
        self.states.forEach {
            guard let content = self.createCase(of: $1) else {
                return
            }
            outputStream.write(content)
            outputStream.write("\n")
        }
        self.acceptingStates.forEach {
            let props = self.extractor.extract(from: $0)
            let conditions = self.createAcceptingTansition(for: props)
            outputStream.write(conditions + "\n\n")
        }
        if self.usingClocks {
            outputStream.write(self.createWaitCase() + "\n\n")
        }
        outputStream.write("TRANS status = \"finished\" -> next(status) = \"finished\";\n\n")
        outputStream.write("TRANS status = \"error\" -> next(status) = \"error\";\n\n")
    }

    fileprivate func createCase(of state: State) -> String? {
        if state.edges.isEmpty {
            self.acceptingStates.insert(state.properties)
            return nil
        }
        var cases: [String: Set<String>] = [:]
        cases.reserveCapacity(state.edges.count)
        let sourceProps = self.extractor.extract(from: state.properties)
        state.edges.forEach { edge in
            if nil == self.states[edge.target] {
                self.acceptingStates.insert(edge.target)
            }
            var constraints: [String: ClockConstraint] = [:]
            if self.usingClocks, let referencingClock = edge.clockName, let constraint = edge.constraint {
                let clockName = self.extractor.convert(label: referencingClock)
                constraints[clockName] = constraint
            }
            let conditions = self.createConditions(of: sourceProps, constraints: constraints)
            let targetProps = self.extractor.extract(from: edge.target)
            let effect: String
            if self.usingClocks {
                effect = self.createEffect(from: targetProps, clockName: edge.clockName, resetClock: edge.resetClock, duration: edge.time)
            } else {
                effect = self.createEffect(from: targetProps)
            }
            if nil == cases[conditions] {
                cases[conditions] = [effect]
            } else {
                cases[conditions]?.insert(effect)
            }
            /*let transition = "TRANS " + conditions + "\n    -> " + effect
            return transition + ";\n"*/
        }
        let transitions = cases.lazy.compactMap { (condition, effects) -> String? in
            let effect = effects.sorted().lazy.map { "(" + $0 + ")" }.combine("") { $0 + "\n    | " + $1  }
            if effect.isEmpty {
                return nil
            }
            return "TRANS " + condition + "\n    -> " + effect + ";\n"
        }
        let combined = transitions.combine("") { $0 + "\n" + $1 }
        return combined.isEmpty ? nil : combined
    }
    
    private func createWaitCase() -> String {
        let condition = "TRANS c < sync"
        let extras = self.usingClocks ? ["next(sync) = sync", "next(c) = sync"] : []
        let clockNames = self.clocks.subtracting(["c"])
        let fullList = (Array(self.properties.keys) + Array(clockNames))
        let effects = fullList.sorted().map { "next(" + $0 + ") = " + $0 } + extras
        let effectList = effects.combine("") { $0 + "\n    & " + $1 }
        return condition + "\n    -> " + effectList + ";"
    }
    
    private func createAcceptingTansition(for props: [String: String]) -> String {
        let condition = self.createConditions(of: props)
        let effect = self.createAcceptingEffect(for: props)
        return "TRANS " + condition + "\n    -> " + effect + ";"
    }
    
    private func createAcceptingEffect(for props: [String: String]) -> String {
        var targetProps = Dictionary<String, String>(minimumCapacity: props.count + self.clocks.count)
        props.forEach {
            targetProps[$0.0] = $0.0
        }
        if self.usingClocks {
            self.clocks.forEach {
                targetProps[$0] = $0
            }
        }
        targetProps["status"] = "\"finished\""
        return self.createEffect(from: targetProps)
    }

    fileprivate func createConditions(of props: [String: String], constraints: [String: ClockConstraint] = [:]) -> String {
        var props = props
        if self.usingClocks, nil == props["c"] {
            props["c"] = "sync"
        }
        let propValues = props.sorted { $0.key <= $1.key }.map { $0 + " = " + $1 }
        let constraintValues = constraints.sorted { $0.key <= $1.key }.map { "(" + self.expression(for: $1.reduced, referencing: $0) + ")" }
        return (propValues + constraintValues).combine("") { $0 + " & " + $1 }
    }
    
    private func expression(for constraint: ClockConstraint, referencing label: String) -> String {
        return constraint.expression(referencing: label, equal: { $0 + "=" + $1 }, and: { $0 + " & " + $1 }, or: { $0 + " | " + $1 })
    }

    fileprivate func createEffect(from props: [String: String], clockName: String? = nil, resetClock: Bool = false, duration: UInt? = nil, forcePC: String? = nil) -> String {
        var props = props
        if nil == props["status"] {
            props["status"] = "\"executing\""
        }
        if self.usingClocks {
            if nil == props["c"] {
                props["c"] = "0"
            }
            if resetClock, let rawClockName = clockName {
                let clockName = self.extractor.convert(label: rawClockName)
                props[clockName] = "0"
            }
            if let duration = duration {
                props["sync"] = "\(duration)"
            } else {
                props["sync"] = "sync"
            }
        }
        let allKeys: Set<String>
        if self.usingClocks {
            allKeys = Set(self.properties.keys).union(self.clocks)
        } else {
            allKeys = Set(self.properties.keys)
        }
        let missingKeys = allKeys.subtracting(Set(props.keys))
        missingKeys.forEach {
            props[$0] = $0
        }
        return props.sorted { $0.key <= $1.key }.lazy.map {
            if let newPC = forcePC, $0.key == "pc" {
                return "next(pc)=" + newPC
            }
            return "next(" + $0.key + ")=" + $0.value
        }.combine("") { $0 + "\n    & " + $1}
    }

}
