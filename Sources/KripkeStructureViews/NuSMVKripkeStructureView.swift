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
        self.clocks = usingClocks ? ["c"] : []
        self.usingClocks = usingClocks
        self.states = Dictionary(minimumCapacity: 500000)
        self.stream = self.outputStreamFactory.make(id: self.identifier + ".smv")
        self.properties = [:]
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
        self.properties["pc"]?.value.insert("\"error\"")
        self.properties["pc"]?.value.insert("\"finish\"")
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
        stream.write("VAR\n\n")
        if self.usingClocks {
            self.clocks.sorted().forEach {
                stream.write("\($0): real;\n")
            }
            stream.write("\n")
        }
        self.properties.forEach {
            guard let first = $1.value.first else {
                stream.write("\($0) : {};\n\n")
                return
            }
            stream.write("\($0) : {\n")
            stream.write("    " + first)
            $1.value.dropFirst().forEach {
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
        let allClocks = self.clocks.sorted()
        stream.write("INIT\n")
        let initials = self.initials.lazy.map {
            var props = $0
            allClocks.forEach {
                props[$0] = "0"
            }
            return "(" + self.createConditions(of: props, includeTime: false) + ")"
        }.combine("") {
            $0 + " | " + $1
        }
        stream.write(initials + ";")
        stream.write("\n\n")
    }

    fileprivate func createTransitions(
        writingTo outputStream: inout TextOutputStream
    ) {
        let trans = "TRANS\ncase\n"
        let endTrans = "esac"
        outputStream.write(trans)
        guard nil != self.firstState else {
            outputStream.write(endTrans)
            return
        }
        self.states.forEach {
            guard let content = self.createCase(of: $1) else {
                return
            }
            self.stream.write(content)
            self.stream.write("\n")
        }
        self.acceptingStates.forEach {
            let props = self.extractor.extract(from: $0)
            let conditions = self.createConditions(of: props)
            let effects = self.createEffect(from: props, forcePC: "\"finish\"")
            outputStream.write(conditions + ":" + "\n")
            outputStream.write("    " + effects + ";\n")
        }
        outputStream.write("pc=\"finish\":next(pc)=\"finish\";\n")
        outputStream.write("TRUE:next(pc)=\"error\";\n")
        outputStream.write(endTrans)
    }

    fileprivate func createCase(of state: State) -> String? {
        let props = self.extractor.extract(from: state.properties)
        let conditions = self.createConditions(of: props)
        let transitions: String = state.edges.lazy.map {
            if nil == self.states[$0.target] {
                self.acceptingStates.insert($0.target)
            }
            let props = self.extractor.extract(from: $0.target)
            let effect: String
            if self.usingClocks {
                effect = self.createEffect(from: props, clockName: $0.clockName, resetClock: $0.resetClock, duration: $0.time)
            } else {
                effect = self.createEffect(from: props)
            }
            return "    (\(effect))"
        }.combine("") { $0 + " |\n" + $1 }
        if transitions.isEmpty {
            return nil
        }
        return conditions + ":\n" + transitions + ";"
    }

    fileprivate func createConditions(of props: [String: String], includeTime: Bool = true) -> String {
        var props = props
        if self.usingClocks && includeTime {
            props["time"] = "c"
        }
        guard let firstProp = props.first else {
            return ""
        }
        let firstCondition = firstProp.0 + "=" + firstProp.1
        return props.dropFirst().reduce(firstCondition) {
            $0 + " & " + $1.0 + "=" + $1.1
        }
    }

    fileprivate func createEffect(from props: [String: String], clockName: String? = nil, resetClock: Bool = false, duration: UInt? = nil, forcePC: String? = nil) -> String {
        var props = props
        if self.usingClocks, let duration = duration {
            props["c"] = "c+\(duration)"
        } else if self.usingClocks {
            props["c"] = "c"
        }
        if self.usingClocks, let clockName = clockName {
            let clockName = self.extractor.convert(label: clockName)
            self.clocks.insert(clockName)
            if let duration = duration {
                props[clockName] = resetClock ? "0" : clockName + "+\(duration)"
            } else {
                props[clockName] = resetClock ? "0" : clockName
            }
        }
        let missingKeys = Set(self.properties.keys).subtracting(Set(props.keys))
        missingKeys.forEach {
            props[$0] = $0
        }
        return props.lazy.map {
            if let newPC = forcePC, $0.key == "pc" {
                return "next(pc)=" + newPC
            }
            return "next(" + $0.key + ")=" + $0.value
        }.combine("") { $0 + " & " + $1}
    }

}
