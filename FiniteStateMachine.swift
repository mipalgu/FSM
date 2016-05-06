/*
 * FiniteStateMachine.swift
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
 *  This contains implementation details for Finite State Machines.  Do not use
 *  this protocol directly.  If you want to create your own implementation of a
 *  Finite State Machine then instead use `FiniteStateMachine`.
 */
public protocol FiniteStateMachineType {
    
    var initialState: State { get }
    var name: String { get }

}

/**
 *  Make finite state machines exitable by default.
 */
public extension FiniteStateMachineType where Self: Exitable, Self: Resumeable {
    
    public mutating func exit() -> Void {
        self.resume()
        self.currentState = EmptyState("_exit")
        self.previousState = self.currentState
    }
    
    public func hasFinished() -> Bool {
        return false == self.isSuspended() &&
            0 == self.currentState.transitions.count &&
            self.currentState == self.previousState
    }
    
}

public extension FiniteStateMachineType where Self: Resumeable {

    public mutating func resume() -> Void {
        if (nil == self.suspendedState) {
            return
        }
        self.currentState = self.suspendedState!
        self.suspendedState = nil
    }

}

/**
 *  Make finite state machines suspendable by default.
 */
public extension FiniteStateMachineType where Self: Suspendable {
    
    public func isSuspended() -> Bool {
        return self.suspendState == self.currentState
    }
    
    public mutating func suspend() -> Void {
        self.suspendedState = self.currentState
        self.currentState = self.suspendState
    }
    
}

/**
 *  Make finite state machines restartable by default.
 */
public extension FiniteStateMachineType where Self: Restartable, Self: Resumeable {
    
    public mutating func restart() -> Void {
        self.resume()
        self.previousState = self.initialPreviousState
        self.currentState = self.initialState
    }
    
}

/**
 *  Make finite state machines state executers by default.
 */
public extension FiniteStateMachineType where Self: StateExecuter {
    
    public mutating func next() {
        let previous: State = self.previousState
        self.previousState = self.currentState
        self.currentState = self.ringlet.execute(
            state: self.currentState,
            previousState: previous
        )
    }
    
}

public func ==<
    T: FiniteStateMachineType, U: FiniteStateMachineType
>(lhs: T, rhs: U) -> Bool {
    return lhs.name == rhs.name
}

/**
 *  A common interface for finite state machines.
 */
public class FiniteStateMachine:
    FiniteStateMachineType,
    Exitable,
    Equatable,
    Restartable,
    Resumeable,
    VariablesContainer
{

    /**
     *  The unique name for the FSM.
     *
     *  Used for equality checks.
     */
    public let name: String
    
    /**
     *  The entry state of the machine.
     */
    public let initialState: State
    
    /**
     *  The initial state of the previous state.
     *
     *  previousState is set to this value on restart.
     */
    public let initialPreviousState: State
    
    /**
     *  The next state that needs to be executed.
     */
    public var currentState: State
    
    /**
     *  The last state that was executed.
     */
    public var previousState: State
    
    /**
     *  An instance of `Ringlet` that is used to execute the states.
     */
    public let ringlet: Ringlet
    
    /**
     *  The state that was about to be executed when the machine was suspended.
     */
    public var suspendedState: State? = nil
    
    /**
     *  The state which is responsible for suspending the machine.
     *
     *  If this state is set as the current state then the machine is determined
     *  to be suspended.
     */
    public let suspendState: State

    /**
     *  Variables that are shared between all states of this Finite State
     *  Machine.
     */
    public var vars: Variables
    
    public init(
        _ name: String,
        initialState: State,
        ringlet: Ringlet = MiPalRinglet(),
        vars: Variables = EmptyVariables(),
        initialPreviousState: State = EmptyState("_previous"),
        suspendedState: State? = nil,
        suspendState: State = EmptyState("_suspend")
    ) {
        self.currentState = initialState
        self.initialPreviousState = initialPreviousState
        self.initialState = initialState
        self.name = name
        self.previousState = initialPreviousState
        self.ringlet = ringlet
        self.suspendedState = suspendedState
        self.suspendState = suspendState
        self.vars = vars
    }
    
}

public typealias FSM = FiniteStateMachine
