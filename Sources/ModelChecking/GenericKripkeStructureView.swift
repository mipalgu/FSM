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
    
    fileprivate var data: GenericKripkeStructureViewData = GenericKripkeStructureViewData()
    
    fileprivate let handler: Handler
    
    fileprivate let inputOutputStreamFactory: InputOutputStreamFactory
    
    fileprivate let outputStreamFactory: OutputStreamFactory
    
    fileprivate var edgeStream: InputOutputStream!
    
    fileprivate var combinedStream: OutputStream!
    
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
        data = GenericKripkeStructureViewData()
        self.combinedStream.write("digraph finite_state_machine {\n")
    }
    
    public func commit(state: State, isInitial: Bool) {
        if true == self.data.alreadyProcessed(state.properties) {
            return
        }
        self.data.markProcessed(state.properties)
        let id = self.data.fetchId(of: state.properties)
        self.handler.handleState(self.data, state: state, withId: id, isInitial: isInitial, usingStream: &self.combinedStream)
        var edgeOutputStream: OutputStream = self.edgeStream
        self.handler.handleEffects(self.data, state: state, withId: id, usingStream: &edgeOutputStream)
        self.edgeStream = edgeOutputStream as! InputOutputStream
    }
    
    public func finish() {
        self.handler.handleInitials(self.data, initials: self.data.initials, usingStream: &self.combinedStream)
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
    
}

extension GenericKripkeStructureView where Handler == GexfKripkeStructureViewHandler<State> {
    
    public convenience init(
        handler: GexfKripkeStructureViewHandler<State> = GexfKripkeStructureViewHandler<State>(),
        inputOutputStreamFactory: InputOutputStreamFactory = FileInputOutputStreamFactory(),
        outputStreamFactory: OutputStreamFactory = FileOutputStreamFactory()
    ) {
        self.init(handler: handler, inputOutputStreamFactory: inputOutputStreamFactory, outputStreamFactory: outputStreamFactory)
    }
    
}
