/*
 * AnyControllableFiniteStateMachine.swift 
 * FSM 
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

import Functional
import KripkeStructure

/**
 *  A type-erased Finite State Machine that can be controlled.
 *
 *  An instance of `AnyControllableFiniteStateMachine` forwards its operations
 *  to an underlying base `FiniteStateMachineType`, wrapping all states within
 *  an `AnyState`, hiding the specifics of the underlying fsm.
 *
 *  - SeeAlso: `AnyState`
 *  - SeeAlso: `FiniteStateMachineType`
 */
public struct AnyControllableFiniteStateMachine:
    FiniteStateMachineType,
    Cloneable,
    StateExecuter,
    Exitable,
    Finishable,
    KripkePropertiesRecordable,
    Resumeable,
    Restartable,
    Snapshotable,
    SnapshotControllerContainer,
    Updateable
{

    public typealias _StateType = AnyState

    public let base: Any

    private let _asScheduleableFiniteStateMachine: () -> AnyScheduleableFiniteStateMachine

    private let _clone: () -> AnyControllableFiniteStateMachine

    private let _currentRecord: () -> KripkeStatePropertyList

    private let _currentState: () -> AnyState

    private let _exit: () -> Void

    private let _externalVariables: () -> [AnySnapshotController]

    private let _setExternalVariables: ([AnySnapshotController]) -> Void

    private let _hasFinished: () -> Bool

    private let _initialState: () -> AnyState

    private let _isSuspended: () -> Bool

    private let _name: () -> String

    private let _next: () -> Void

    private let _restart: () -> Void

    private let _resume: () -> Void

    private let _suspend: () -> Void

    private let _saveSnapshot: () -> Void

    private let _takeSnapshot: () -> Void

    private let _update: ([String: Any]) -> Void

    public var currentRecord: KripkeStatePropertyList {
        return self._currentRecord()
    }

    public var asScheduleableFiniteStateMachine: AnyScheduleableFiniteStateMachine {
        return self._asScheduleableFiniteStateMachine()
    }

    /**
     *  The next state to execute.
     *
     *  - Attention: This state is read-only, attempting to set this to a new
     *  value will not do anything.
     */
    public var currentState: AnyState {
        get {
            return self._currentState()
        } set {}
    }

    public var externalVariables: [AnySnapshotController] {
        get {
            return self._externalVariables()
        } set {
            self._setExternalVariables(newValue)
        }
    }

    /**
     *  Has the Finite State Machine finished?
     */
    public var hasFinished: Bool {
        return self._hasFinished()
    }

    /**
     *  The first state that the Finite State Machine would execute.
     */
    public var initialState: AnyState {
        return self._initialState()
    }

    /**
     *  Is the Finite State Machine suspended?
     */
    public var isSuspended: Bool {
        return self._isSuspended()
    }

    /**
     *  The name of the Finite State Machine.
     *
     *  - Warning: This must be unique between Finite State Machines.
     */
    public var name: String {
        return self._name()
    }

    /**
     *  Creates a new `AnyScheduleableFiniteStateMachine` that wraps and
     *  forwards operations to `base`.
     */
    public init<FSM: FiniteStateMachineType>(_ base: FSM) where
        FSM: Cloneable,
        FSM: StateExecuter,
        FSM: Exitable,
        FSM: Finishable,
        FSM: KripkePropertiesRecordable,
        FSM: Resumeable,
        FSM: Restartable,
        FSM: Snapshotable,
        FSM: SnapshotControllerContainer,
        FSM: Updateable
    {
	    self.base = base
        var base = base
        self._asScheduleableFiniteStateMachine = { AnyScheduleableFiniteStateMachine(base) }
        self._clone = { AnyControllableFiniteStateMachine(base.clone()) }
        self._currentRecord = { base.currentRecord }
        self._currentState = { AnyState(base.currentState) }
        self._exit = { base.exit() }
        self._setExternalVariables = { base.externalVariables = $0 }
        self._externalVariables = { base.externalVariables }
        self._hasFinished = { base.hasFinished }
        self._initialState = { AnyState(base.initialState) }
        self._isSuspended = { base.isSuspended }
        self._name = { base.name }
        self._next = { base.next() }
        self._restart = { base.restart() }
        self._resume = { base.resume() }
        self._suspend = { base.suspend() }
        self._saveSnapshot = { base.saveSnapshot() }
        self._takeSnapshot = { base.takeSnapshot() }
        self._update = { base.update(fromDictionary: $0) }
    }

    public func clone() -> AnyControllableFiniteStateMachine {
        return self._clone()
    }

    /**
     *  Stop the Finite State Machine from running.
     *
     *  - Postcondition: `hasFinished` is true.
     */
    public func exit() {
        self._exit()
    }

    /**
     *  Execute the next state.
     */
    public func next() {
        self._next()
    }

    /**
     *  Restart the Finite State Machine.
     */
    public func restart() {
        self._restart()
    }

    /**
     *  Resume the Finite State Machine so that it is no longer suspended.
     */
    public func resume() {
        self._resume()
    }

    /**
     *  Suspend the Finite State Machine.
     */
    public func suspend() {
        self._suspend()
    }

    public func saveSnapshot() {
        self._saveSnapshot()
    }

    public func takeSnapshot() {
        self._takeSnapshot()
    }

    public func update(fromDictionary dictionary: [String: Any]) {
        self._update(dictionary)
    }

 }
