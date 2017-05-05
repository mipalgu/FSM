/*
 * KripkeMiPalRinglet.swift
 * swiftfsm
 *
 * Created by Callum McColl on 22/01/2016.
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

import KripkeStructure

/**
 *  A standard ringlet.
 *
 *  Firstly calls onEntry if this state has just been transitioned into.  If a
 *  transition is possible then the states onExit method is called and the new
 *  state is returned.  If no transitions are possible then the main method is
 *  called and the state is returned.
 */
public final class KripkeMiPalRinglet<
    V: VariablesContainer,
    E: PropertiesExtractor
> : MiPalRinglet, KripkeRinglet {

    /**
     *  This `Ringlet` only works with `MiPalState`s.
     */
    public typealias _StateType = MiPalState

    private let extractor: E

    /**
     *  The `Variables` that the Finite State Machine has access to.
     */
    public private(set) var fsmVars: V
    
    /**
     *  Then snapshots of all the variables from the last state execution.
     */
    public private(set) var snapshots: [KripkeStatePropertyList] = []

    /**
     *  Create a new `KripkeMiPalRinglet`.
     *
     *  - Parameter externalVariables: The `ExternalVariables` within an
     *  `ExternalVariablesContainer` within an `AnySnapshotController`.
     *
     *  - Parameter fsmVars: The `Variables` that the Finite State Machine has
     *  access to.
     *
     *  - Parameter extractor: Used to extract the values of the
     *  `ExternalVariables`, Finite State Machine `Variables` and the state
     *  variables.
     *
     *  - Parameter previousState: The last `MiPalState` that was executed.
     *  This is used to check whether to run the `MiPalState.onEntry()`.
     */
    public init(
        externalVariables: [AnySnapshotController],
        fsmVars: V,
        extractor: E,
        previousState: MiPalState = EmptyMiPalState("_previous")
    ) {
        self.fsmVars = fsmVars
        self.extractor = extractor
        super.init(externalVariables: externalVariables, previousState: previousState)
    }

    /**
     *  Create a new instance of `KripkeMiPalRinglet` that is an exact copy of
     *  `self`.
     */
    public final func clone() -> KripkeMiPalRinglet {
        return KripkeMiPalRinglet(
            externalVariables: self.externalVariables,
            fsmVars: self.fsmVars,
            extractor: self.extractor,
            previousState: self.previousState
        )
    }

    /**
     *  Execute the ringlet while taking snapshots of all the variables.
     *
     *  Returns a state representing the next state to execute.
     */
    public override func execute(state: MiPalState) -> MiPalState {
        self.snapshots = []
        // Take a snapshot
        self.record(state: state)
        // Call onEntry if we have just transitioned to this state. 
        if (state != previousState) {
            state.onEntry()
            self.record(state: state)
        }
        self.previousState = state
        // Can we transition to another state?
        if let t = state.transitions.lazy.filter(self.isValid(forState: state)).first {
            // Yes - Exit state and return the new state.
            state.onExit()
            self.record(state: state)
            return t.target
        }
        // No - Execute main method and return state.
        state.main()
        self.record(state: state)
        return state
    }

    private func record(state: MiPalState) {
        self.snapshots.append(
            self.extractor.extract(
                externalVariables: self.externalVariables,
                fsmVars: self.fsmVars.vars,
                state: state
            )
        )
    }

    private func isValid(
        forState state: MiPalState
    ) -> (Transition<MiPalState, MiPalState>) -> Bool {
        return {
            let valid: Bool = $0.canTransition(state)
            self.record(state: state)
            return valid
        }
    }

}
