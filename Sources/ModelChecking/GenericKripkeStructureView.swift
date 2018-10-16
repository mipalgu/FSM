/*
 * GenericKripkeStructureView.swift
 * ModelChecking
 *
 * Created by Callum McColl on 17/10/18.
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

public final class GenericKripkeStructureView<Handler: GenericKripkeStructureViewHandler, State: KripkeStateType>: KripkeStructureView where Handler.State == State {
    
    fileprivate let handler: Handler
    
    fileprivate let inputOutputStreamFactory: InputOutputStreamFactory
    
    fileprivate let outputStreamFactory: OutputStreamFactory
    
    fileprivate var edgeStream: InputOutputStream!
    
    fileprivate var combinedStream: OutputStream!
    
    fileprivate var ids: [Int: Int] = [:]
    
    fileprivate var processList: HashSink<KripkeStatePropertyList> = HashSink(minimumCapacity: 500000)
    
    fileprivate var initials: Set<Int> = []
    
    fileprivate var latest: Int = 0
    
    public init(
        handler: Handler,
        inputOutputStreamFactory: InputOutputStreamFactory = FileInputOutputStreamFactory(),
        outputStreamFactory: OutputStreamFactory = FileOutputStreamFactory()
    ) {
        self.handler = handler
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
        self.processList.insert(state.properties)
        let id = self.fetchId(of: state.properties)
        self.handler.handleState(self, state: state, withId: id, isInitial: isInitial, usingStream: &self.combinedStream)
        self.handler.handleEffects(self, state: state, withId: id, usingStream: &self.edgeStream)
    }
    
    public func finish() {
        self.handler.handleInitials(self, usingStream: &self.combinedStream)
        self.edgeStream.flush()
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
    
    public func fetchId(of props: KripkeStatePropertyList) -> Int {
        let hashValue = Hashing.hashValue(of: props)
        if let found = self.ids[hashValue] {
            return found
        }
        let id = self.latest
        self.latest += 1
        self.ids[hashValue] = id
        return id
    }
    
}
