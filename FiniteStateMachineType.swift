/*
 * FiniteStateMachineType.swift 
 * FSM 
 *
 * Created by Callum McColl on 29/06/2016.
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

/**
 *  Contains implementation details for Finite State Machines.
 *
 *  - Warning: Do not use this protocol directly.  If you wish to create your
 *  own implementation of a Finite State Machine then instead make a subclass
 *  of `FiniteStateMachine`.
 */
public protocol FiniteStateMachineType: Identifiable, StateContainer {
    
    var initialState: _StateType { get }

}

/**
 *  Provide default implementations for when a Finite State Machine is Exitable.
 */
public extension FiniteStateMachineType where
    Self: ExitableStateExecuter,
    Self: Resumeable
{

    /**
     *  The Finite State Machine is resumed and `currentState` is set to an
     *  accepting state, `previousState` is set to `currentState`.
     *
     *  This therefore make `hasFinished` true.
     */
    public mutating func exit() {
        self.resume()
        self.currentState = self.exitState
        self.previousState = self.currentState
    }
    
}

public extension FiniteStateMachineType where
    Self._StateType: Transitionable,
    Self: Finishable,
    Self: Suspendable
{

    /**
     *  Finite State Machine are finished if they are not suspended,
     *  `currentState` is an accepting state and `currentState` has already been
     *  executed.
     */
    var hasFinished: Bool {
        return false == self.isSuspended &&
            0 == self.currentState.transitions.count &&
            self.currentState == self.previousState
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
public extension FiniteStateMachineType where Self._StateType: Equatable, Self: Suspendable {
    
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
public extension FiniteStateMachineType where
    Self: StateExecuterDelegator,
    Self._StateType == Self.RingletType._StateType
{
    
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
        self.previousState = self.currentState
        self.currentState = self.ringlet.execute(state: self.currentState)
    }
    
}

public extension FiniteStateMachineType where
    Self: SnapshotContainer,
    Self: StateExecuterDelegator,
    Self.RingletType: SnapshotContainer
{

    public var snapshots: [KripkeStatePropertyList] {
        return self.ringlet.snapshots
    }

}
