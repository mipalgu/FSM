/*
 * GraphVizKripkeStructureView.swift 
 * Verification 
 *
 * Created by Callum McColl on 26/02/2018.
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
import swift_helpers
import KripkeStructure
import Utilities

public final class GraphVizKripkeStructureView<State: KripkeStateType>: KripkeStructureView {

    fileprivate let inputOutputStreamFactory: InputOutputStreamFactory
    
    fileprivate let outputStreamFactory: OutputStreamFactory
    
    fileprivate var edgeStream: InputOutputStream!
    
    fileprivate var combinedStream: OutputStream!
    
    fileprivate var ids: [Int: Int] = [:]
    
    fileprivate var processList: HashSink<KripkeStatePropertyList> = HashSink(minimumCapacity: 500000)
    
    fileprivate var initials: Set<Int> = []

    fileprivate var latest: Int = 0

    /**
     *  Create a new `NuSMVKripkeStructureView`.
     *
     *  - Parameter factory: Used to create the `Printer` that will output the
     *  NuSMV representation of the `KripkeStructure`.
     *
     *  - Parameter delimiter: Used to place in between identifiers.  For
     *  example, the program counter is represented as:
     *  <machine_name>-<fsm_name>-<state_name>-<snapshot_count> where "-" is the
     *  delimiter.
     */
    public init(
        inputOutputStreamFactory: InputOutputStreamFactory = FileInputOutputStreamFactory(),
        outputStreamFactory: OutputStreamFactory = FileOutputStreamFactory()
    ) {
        self.inputOutputStreamFactory = inputOutputStreamFactory
        self.outputStreamFactory = outputStreamFactory
    }
    
    public func reset() {
        self.edgeStream = self.inputOutputStreamFactory.make(id: "edges.gv")
        self.combinedStream = self.outputStreamFactory.make(id: "kripke_structure.gv")
        self.ids = [:]
        self.latest = 0
        self.initials = []
        self.processList = HashSink(minimumCapacity: 500000)
        self.combinedStream.write("digraph finite_state_machine {\n")
    }
    
    public func commit(state: State, isInitial: Bool) {
        if true == self.processList.contains(state.properties) {
            return
        }
        let id = self.fetchId(of: state.properties)
        self.handleState(state: state, withId: id, isInitial: isInitial, usingStream: &self.combinedStream)
        self.handleEffects(state: state, withId: id, usingStream: &self.edgeStream)
    }
    
    public func finish() {
        self.handleInitials(usingStream: &self.combinedStream)
        self.edgeStream.flush()
        self.combinedStream.flush()
        self.edgeStream.rewind()
        while let line = self.edgeStream.readLine() {
            self.combinedStream.write(line)
            self.combinedStream.write("\n")
        }
        self.combinedStream.write("}")
        self.combinedStream.flush()
        self.edgeStream.close()
        self.combinedStream.close()
    }
    
    fileprivate func fetchId(of props: KripkeStatePropertyList) -> Int {
        let hashValue = Hashing.hashValue(of: props)
        let id: Int
        if let found = self.ids[hashValue] {
            id = found
        } else {
            id = latest
            latest += 1
        }
        return id
    }

    fileprivate func handleState(state: State, withId id: Int, isInitial: Bool, usingStream stream: inout OutputStream) {
        let shape = state.effects.isEmpty ? "doublecircle" : "circle"
        guard let label = self.formatProperties(list: state.properties, indent: 1, includeBraces: false) else {
            return
        }
        if true == isInitial {
            stream.write("node [shape=point] si\(id);")
            self.initials.insert(id)
        }
        stream.write("node [shape=\(shape), label=\"\(label)\"]; s\(id);\n")
    }
    
    fileprivate func handleInitials(usingStream stream: inout OutputStream) {
        self.initials.forEach {
            stream.write("si\($0) -> s\($0);\n")
        }
    }
    
    fileprivate func handleEffects(state: State, withId id: Int, usingStream stream: inout InputOutputStream) {
        state.effects.forEach {
            let effectId = self.fetchId(of: $0)
            stream.write("s\(id) -> s\(effectId);\n")
        }
    }

    fileprivate func formatProperties(list: KripkeStatePropertyList, indent: Int, includeBraces: Bool = true) -> String? {
        let indentStr = Array(repeating: " ", count: (indent + 1) * 2).reduce("", +)
        let list = list.sorted { $0.0 < $1.0 }
        let props = list.compactMap { (key: String, val: KripkeStateProperty) -> String? in
            guard let prop = self.formatProperty(val, indent + 1) else {
                return nil
            }
            return "\\l" + indentStr + key + " = " + prop
        }
        if props.isEmpty {
            return nil
        }
        let content = props.combine("") { $0 + "," + $1 }
        let indentStr2 = Array(repeating: " ", count: indent * 2).combine("", +)
        if true == includeBraces {
            return "{" + content + "\\l" + indentStr2 + "}"
        }
        return content + "\\l" + indentStr2
    }

    fileprivate func formatProperty(_ prop: KripkeStateProperty, _ indent: Int) -> String? {
        switch prop.type {
        case .EmptyCollection:
            return "[]"
        case .Collection(let collection):
            if collection.isEmpty {
                return "[]"
            }
            let indentStr = Array(repeating: " ", count: indent * 2).reduce("", +)
            let indentStr2 = Array(repeating: " ", count: (indent + 1) * 2).reduce("", +)
            let props = collection.compactMap { (val: KripkeStateProperty) -> String? in
                self.formatProperty(val, indent + 1)
            }
            if props.isEmpty {
                return nil
            }
            return "[\\l" + indentStr2 + props.combine("") { $0 + ",\\l" + indentStr2 + $1 } + "\\l" + indentStr + "]"
        case .Compound(let list):
            return self.formatProperties(list: list, indent: indent + 1)
        default:
            return "\(prop.value)"
        }
    }

}
