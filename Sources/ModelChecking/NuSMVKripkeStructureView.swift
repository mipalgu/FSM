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
import Utilities

public final class NuSMVKripkeStructureView<State: KripkeStateType>: KripkeStructureView {
    
    fileprivate let extractor: PropertyExtractor<NuSMVPropertyFormatter>
    
    fileprivate let inputOutputStreamFactory: InputOutputStreamFactory
    
    fileprivate let outputStreamFactory: OutputStreamFactory
    
    fileprivate var stream: InputOutputStream!
    
    fileprivate var properties: [String: Ref<Set<String>>] = [:]
    
    fileprivate var sink: HashSink<KripkeStatePropertyList> = HashSink(minimumCapacity: 500000)
    
    fileprivate var firstState: State?
    
    fileprivate var initials: Set<[String: String]> = []
    
    public init(
        extractor: PropertyExtractor<NuSMVPropertyFormatter> = PropertyExtractor(formatter: NuSMVPropertyFormatter()),
        inputOutputStreamFactory: InputOutputStreamFactory = FileInputOutputStreamFactory(),
        outputStreamFactory: OutputStreamFactory = FileOutputStreamFactory()
    ) {
        self.extractor = extractor
        self.inputOutputStreamFactory = inputOutputStreamFactory
        self.outputStreamFactory = outputStreamFactory
    }
    
    public func reset() {
        self.sink = HashSink(minimumCapacity: 500000)
        self.stream = self.inputOutputStreamFactory.make(id: "main.transitions.smv")
        self.properties = [:]
        self.firstState = nil
        self.initials = []
    }
    
    public func commit(state: State, isInitial: Bool) {
        if nil == self.firstState {
            self.firstState = state
        }
        if sink.contains(state.properties) {
            return
        }
        sink.insert(state.properties)
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
        self.stream.write(self.createCase(of: state))
        self.stream.write("\n")
    }
    
    public func finish() {
        self.stream.flush()
        self.stream.rewind()
        var combinedStream = self.outputStreamFactory.make(id: "main.smv")
        defer { combinedStream.close() }
        combinedStream.write("MODULE main\n\n")
        var outputStream: TextOutputStream = combinedStream
        self.createPropertiesList(usingStream: &outputStream)
        self.createInitial(usingStream: &outputStream)
        self.createTransitions(readingFrom: self.stream, writingTo: &outputStream)
        combinedStream.flush()
        self.stream.close()
    }
    
    fileprivate func createPropertiesList(usingStream stream: inout TextOutputStream) {
        stream.write("VAR\n\n")
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
        guard let firstProperties = self.initials.first else {
            stream.write("INIT()\n")
            return
        }
        stream.write("INIT\n")
        stream.write("(")
        stream.write(self.createConditions(of: firstProperties))
        stream.write(")")
        self.initials.dropFirst().forEach {
            stream.write(" | (")
            stream.write(self.createConditions(of: $0))
            stream.write(")")
        }
        stream.write("\n")
    }
    
    fileprivate func createTransitions(readingFrom inputStream: TextInputStream, writingTo outputStream: inout TextOutputStream) {
        let trans = "TRANS\ncase\n"
        let endTrans = "esac"
        outputStream.write(trans)
        guard let first = self.firstState else {
            outputStream.write(endTrans)
            return
        }
        while let line = inputStream.readLine() {
            outputStream.write(line)
            outputStream.write("\n")
        }
        outputStream.write(self.createTrueCase(with: first))
        outputStream.write("\n")
        outputStream.write(endTrans)
    }
    
    fileprivate func createTrueCase(with state: State) -> String {
        let props = self.extractor.extract(from: state.properties)
        let effects = self.createEffect(from: props)
        return "TRUE:" + effects + ";"
    }
    
    fileprivate func createCase(of state: State) -> String {
        let props = self.extractor.extract(from: state.properties)
        let effects = state.effects.map {
            self.extractor.extract(from: $0)
        }
        let conditions = self.createConditions(of: props)
        guard let firstEffect = effects.first else {
            return ""
        }
        let firstEffects = "    (" + self.createEffect(from: firstEffect) + ")"
        let effectsList = effects.dropFirst().reduce(firstEffects) { (last: String, props: [String: String]) -> String in
            last + " |\n    (" + self.createEffect(from: props) + ")"
        }
        return conditions + ":\n" + effectsList + ";"
    }
    
    fileprivate func createConditions(of props: [String: String]) -> String {
        guard let firstProp = props.first else {
            return ""
        }
        let firstCondition = firstProp.0 + "=" + firstProp.1
        return props.dropFirst().reduce(firstCondition) {
            $0 + " & " + $1.0 + "=" + $1.1
        }
    }
    
    fileprivate func createEffect(from props: [String: String]) -> String {
        guard let firstProp = props.first else {
            return ""
        }
        let firstEffect = "next(" + firstProp.0 + ")=" + firstProp.1
        let effects = props.dropFirst().reduce(firstEffect) {
            $0 + " & next(" + $1.0 + ")=" + $1.1
        }
        return effects
    }
    
}
