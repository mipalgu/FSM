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
 *  Contains implementation details for Finite State Machines.
 *
 *  - Warning: Do not use this protocol directly.  If you wish to create your
 *  own implementation of a Finite State Machine then instead make a subclass
 *  of `FiniteStateMachine`.
 */
public protocol FiniteStateMachineType: StateExecuter {
    
    var initialState: State { get }
    var name: String { get }

}

/**
 *  Provide default implementations for when a Finite State Machine is Exitable.
 */
public extension FiniteStateMachineType where Self: Exitable, Self: Resumeable {
    
    /**
     *  Finite State Machine are finished if they are not suspended,
     *  `currentState` is an accepting state and `currentState` has already been
     *  executed.
     */
    var hasFinished: Bool {
        return false == self.isSuspended() &&
            0 == self.currentState.transitions.count &&
            self.currentState == self.previousState
    }

    /**
     *  The Finite State Machine is resumed and `currentState` is set to an
     *  accepting state, `previousState` is set to `currentState`.
     *
     *  This therefore make `hasFinished` true.
     */
    public mutating func exit() {
        self.resume()
        self.currentState = EmptyState("_exit")
        self.previousState = self.currentState
    }
    
}

/**
 *  Provide default implemtations for when a Finite State Machine is Resumeable.
 */
public extension FiniteStateMachineType where Self: Resumeable {

    /**
     *  Resume the Finite State Machine.
     *
     *  Sets `currentState` to `suspendedState` and sets `suspendedState` to
     *  nil.
     *
     *  The effectively resumes the Finite State Machine so that it may continue
     *  executing.
     *
     *  - Precondition: The Finite State Machine must be suspended.
     */
    public mutating func resume() {
        if (nil == self.suspendedState) {
            return
        }
        self.currentState = self.suspendedState!
        self.suspendedState = nil
    }

}

/**
 *  Provide default implementations for when a Finite State Machine is
 *  Suspendable.
 */
public extension FiniteStateMachineType where Self: Suspendable {
    
    /**
     *  Is the Finite State Machine currently suspended?
     *  
     *  This is only true if `suspendState` equals `currentState`.
     */
    var isSuspended: Bool {
        return self.suspendState == self.currentState
    }
    
    /**
     *  Suspend the Finite State Machine.
     *
     *  Sets `suspendedState` to `currentState` and sets`currentState` to
     *  `suspendState`.
     *
     *  - Precondition: The Finite State Machine must not be suspended.
     */
    public mutating func suspend() {
        if (true == self.isSuspended) {
            return
        }
        self.suspendedState = self.currentState
        self.currentState = self.suspendState
    }
    
}

/**
 *  Provide default implementations for when a Finite State Machine is
 *  Restartable and Resumeable.
 */
public extension FiniteStateMachineType where Self: Restartable, Self: Resumeable {
    
    /**
     *  Restart the Finite State Machine.
     *
     *  Effectively sets `currentState` to `initialState`.
     *
     *  If the Finite State Machine was suspended before `restart()` is called
     *  then the Finite State Machine is resumed.
     */
    public mutating func restart() {
        self.resume()
        self.previousState = self.initialPreviousState
        self.currentState = self.initialState
    }
    
}

/**
 *  Provide default implementations for when a Finite State Machine is a
 *  StateExecuter.
 */
public extension FiniteStateMachineType where Self: StateExecuter {
    
    /**
     *  Executes `currentState`.
     *
     *  Once `currentState` is executed, `previousState` is set to
     *  `currentState` and the state that is to be executed next is set to
     *  `currentState`.
     *
     *  This method uses `ringlet` to execute the `currentState` and the state
     *  that is returned from `ringlet.execute` is the next state to execute.
     */
    public mutating func next() {
        let previous: State = self.previousState
        self.previousState = self.currentState
        self.currentState = self.ringlet.execute(
            state: self.currentState,
            previousState: previous
        )
    }
    
}

/**
 *  Compare each Finite State Machines name for equality.
 */
public func ==<
    T: FiniteStateMachineType, U: FiniteStateMachineType
>(lhs: T, rhs: U) -> Bool {
    return lhs.name == rhs.name
}

/**
 *  A Finite State Machine.
 *
 *  Finite State Machines (FSMs) are defined as an algorithm that can be in any
 *  number of a finite set of states.  Each state therefore represents a single
 *  situation that a Finite State Machine can be in, and executes certain logic.
 *
 *  An FSM must contain a state that is labelled the initial state, which
 *  represents where the FSM starts its execution.  The `initialState` property
 *  represents this state.
 *
 *  The actual execution logic is seperated into seperate types that conform to
 *  the `Ringlet` protocol.  The FSM therefore delegates the execution of its 
 *  states to `ringlet`.
 *
 *  The FSM keeps track of what to execute with the `currentState` and
 *  `previousState` properties.  The `currentState` represents the next state to
 *  execute and the `previousState` represents the last state that was executed.
 *  
 *  An FSM is capable of being suspended, in which case the FSM uses the 
 *  `suspendState` and `suspendedState`.  Instead of doing something similar to
 *  making `currentState` an optional state when we suspend, the FSM first sets
 *  the `suspendedState` to `currentState` and then sets `currentState` to
 *  `suspendState`.  `suspendState` therefore represents the state that is
 *  executed when the FSM is suspended.  The `suspendedState` represents the
 *  next state to execute once the FSM is resumed after being suspended.
 *
 *  An FSM is also a `VariablesContainer`.  Every state that is executed has
 *  access to FSM local variables, or rather variables that are shared amongst
 *  all the states of an FSM.  The FSM therefore stores these variables in
 *  `vars`.
 *  
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
     *  The entry state of the FSM.
     */
    public let initialState: State
    
    /**
     *  The initial state of the previous state.
     *
     *  `previousState` is set to this value on restart.
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
     *  The state that was about to be executed when the FSM was suspended.
     */
    public var suspendedState: State? = nil
    
    /**
     *  The state which is responsible for suspending the FSM.
     *
     *  If this state is set as the current state then the FSM is suspended.
     */
    public let suspendState: State

    /**
     *  Variables that are shared between all states of this FSM.
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

/**
 *  Provide the ability to create a `FiniteStateMachine` by using the shorter
 *  `FSM` type.
 *
 *  This is just some syntactic sugar.
 */
public typealias FSM = FiniteStateMachine
