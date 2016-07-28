/*
 * AnyScheduleableFiniteStateMachine.swift 
 * FSM 
 *
 * Created by Callum McColl on 28/07/2016.
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

public class AnyScheduleableFiniteStateMachine:
    FiniteStateMachineType,
    StateExecuter,
    Finishable,
    Resumeable,
    SnapshotContainer
{

    public typealias _StateType = AnyState

    private let _currentState: () -> AnyState

    private let _hasFinished: () -> Bool

    private let _initialState: () -> AnyState

    private let _isSuspended: () -> Bool

    private let _name: () -> String

    private let _next: () -> Void

    private let _previousState: () -> AnyState

    private let _resume: () -> Void

    private let _snapshots: () -> [Snapshot]

    private let _suspend: () -> Void

    private let _suspendedState: () -> AnyState?

    private let _suspendState: () -> AnyState

    public var currentState: AnyState {
        get {
            return self._currentState()
        } set {}
    }

    public var hasFinished: Bool {
        return self._hasFinished()
    }

    public var initialState: AnyState {
        return self._initialState()
    }

    public var isSuspended: Bool {
        return self._isSuspended()
    }

    public var name: String {
        return self._name()
    }

    public var previousState: AnyState {
        get {
            return self._previousState()
        } set {}
    }

    public var snapshots: [Snapshot] {
        return self._snapshots()
    }

    public var suspendedState: AnyState? {
        get {
            return self._suspendedState()
        } set {}
    }

    public var suspendState: AnyState {
        return self._suspendState()
    }

    public init<
        FSM: FiniteStateMachineType where
        FSM: StateExecuter,
        FSM: Finishable,
        FSM: Resumeable,
        FSM: SnapshotContainer
    >(_ base: FSM) {
        var base = base
        self._currentState = { AnyState(base.currentState) }
        self._hasFinished = { base.hasFinished }
        self._initialState = { AnyState(base.initialState) }
        self._isSuspended = { base.isSuspended }
        self._name = { base.name }
        self._next = { base.next() }
        self._previousState = { AnyState(base.previousState) }
        self._resume = { base.resume() }
        self._snapshots = { base.snapshots }
        self._suspend = { base.suspend() }
        self._suspendedState = { { AnyState($0) } <^> base.suspendedState }
        self._suspendState = { AnyState(base.suspendState) }
    }

    public func next() {
        self._next()
    }

    public func resume() {
        self._resume()
    }

    public func suspend() {
        self._suspend()
    }

 }
