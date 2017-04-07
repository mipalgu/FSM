/*
 * MiPalRinglet.swift
 * swiftfsm
 *
 * Created by Callum McColl on 12/08/2015.
 * Copyright © 2015 Callum McColl. All rights reserved.
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

/**
 *  A standard ringlet.
 *
 *  Firstly calls onEntry if we have just transitioned to this state.  If a
 *  transition is possible then the states onExit method is called and the new
 *  state is returned.  If no transitions are possible then the main method is
 *  called and the state is returned.
 */
public class MiPalRinglet: Ringlet {

    /**
     *  Used to take and save snapshots of the `ExternalVariables`.
     */
    public private(set) var externalVariables: [AnySnapshotController]

    internal var previousState: MiPalState

    /**
     *  Create a new `MiPalRinglet`.
     *
     *  - Parameter externalVariables: Used to take and save snapshots of the
     *  `ExternalVariables`.
     *
     *  - Parameter previousState:  The last `MiPalState` that was executed.
     *  This is used to check whether the `MiPalState.onEntry()` should run.
     */
    public init(
        externalVariables: [AnySnapshotController] = [],
        previousState: MiPalState = EmptyMiPalState("_previous")
    ) {
        self.externalVariables = externalVariables 
        self.previousState = previousState
    }
    
    /**
     *  Execute the ringlet.
     *
     *  - Parameter state: The `MiPalState` that is being executed.
     *
     *  - Returns: A state representing the next state to execute.
     */
    public func execute(state: MiPalState) -> MiPalState {
        // Take a snapshot
        self.takeSnapshot()
        // Call onEntry if we have just transitioned to this state. 
        if (state != self.previousState) {
            state.onEntry()
        }
        self.previousState = state
        // Can we transition to another state?
        if let t = state.transitions.lazy.filter({ $0.canTransition(state) }).first {
            // Yes - Exit state and return the new state.
            state.onExit()
            self.saveSnapshot()
            return t.target
        }
        // No - Execute main method and return state.
        state.main()
        self.saveSnapshot()
        return state
    }

    internal func takeSnapshot() {
        let _ = self.externalVariables.map { $0.takeSnapshot() }
    }

    internal func saveSnapshot() {
        let _ = self.externalVariables.map { $0.saveSnapshot() }
    }
    
}