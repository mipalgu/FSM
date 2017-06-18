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

import KripkeStructure

/**
 *  A `FiniteStateMachineType` that incorporates the default implementations, 
 *  without Kripke Structure generation capabilities.
 *
 *  This type satisfies all requirements to be scheduleable as it can be used
 *  as an `AnyScheduleableFiniteStateMachine`.
 *
 *  This type uses a `Ringlet` in order to perform state execution.  Therefore
 *  `FiniteStateMachine_StateType` should be equal to the `Ringlet._StateType`.
 *
 *  - Warning: Using this type ensures that no `KripkeStructure` generation is
 *  possible.  If you would like to be able to generate a `KripkeStructure` then
 *  you should use `KripkeFiniteStateMachine`.
 *
 *  - SeeAlso: `FiniteStateMachineType`
 *  - SeeAlso: `KripkeFiniteStateMachine`
 */
public struct FiniteStateMachine<R: Ringlet, KR: KripkePropertiesRecorder, V: VariablesContainer>: FiniteStateMachineType,
    Cloneable,
    ExitableStateExecuter,
    KripkePropertiesRecordable,
    KripkePropertiesRecorderDelegator,
    OptimizedStateExecuter,
    Restartable,
    Resumeable,
    StateExecuterDelegator,
    Snapshotable,
    SnapshotControllerContainer,
    Updateable where
    R: Cloneable,
    R._StateType: Transitionable,
    R._StateType._TransitionType == Transition<R._StateType, R._StateType>,
    R._StateType: Cloneable,
    R._StateType: Updateable,
    V.Vars: Updateable
{

    /**
     *  The type of the states.
     */
    public typealias _StateType = R._StateType

    public typealias Recorder = KR

    /**
     *  The state that is currently executing.
     */
    public var currentState: R._StateType

    public var currentRecord: KripkeStatePropertyList {
        return [
            "externalVariables": KripkeStateProperty(
                type: .Collection(self.externalVariables.map {
                    KripkeStateProperty(
                        type: .Compound(self.recorder.takeRecord(of: $0.val)),
                        value: $0.val
                    )
                }),
                value: self.externalVariables.map { $0.val }
            ),
            "fsmVars": KripkeStateProperty(type: .Compound(self.recorder.takeRecord(of: self.fsmVars.vars)), value: self.fsmVars.vars),
            "\(self.currentState.name)": KripkeStateProperty(type: .Compound(self.recorder.takeRecord(of: self.currentState)), value: self.currentState),
            "currentState": KripkeStateProperty(type: .String, value: self.currentState.name)
        ]
    }

    /**
     *  The state that is used to exit the FSM.
     */
    public let exitState: R._StateType

    public var externalVariables: [AnySnapshotController]

    public let fsmVars: V

    /**
     *  The initial state of the previous state.
     *
     *  `previousState` is set to this value on restart.
     */
    public let initialPreviousState: R._StateType

    /**
     *  The starting state of the FSM.
     */
    public let initialState: R._StateType

    /**
     *  The name of the FSM.
     *
     *  - Warning: This must be unique between FSMs.
     */
    public let name: String

    /**
     *  The last state that was executed.
     */
    public var previousState: R._StateType

    /**
     *  The `KripkePropertiesRecorder` responsible for recording all the
     *  variables used in formal verification.
     */
    public let recorder: Recorder

    /**
     *  An instance of `Ringlet` that is used to execute the states.
     */
    public let ringlet: R

    /**
     *  The state that was the `currentState` before the FSM was suspended.
     */
    public var suspendedState: R._StateType?

    /**
     *  The state that is set to `currentState` when the FSM is suspended.
     */
    public let suspendState: R._StateType
    
    /**
     *  Create a new `FiniteStateMachine`.
     *
     *  - Parameter name: The name of the FSM.
     *
     *  - Parameter initialState: The starting state of the FSM.
     *
     *  - Parameter ringlet: The `Ringlet` that will execute the states.
     *
     *  - Parameter initialPrevious: The starting value of `previousState`.
     *
     *  - Parameter suspendedState: The state that will be set to `currentState`
     *  once the FSM is resumed.  Setting this to a value that is not nil will
     *  force the FSM to be suspended.
     *
     *  - Parameter suspendState: The state that is set to `currentState` once
     *  the FSM is suspended.
     *
     *  - Parameter exitState: The state that is set to `currentState` once
     *  `exit()` is called.  This should be an accepting state.
     */
    public init(
        _ name: String,
        initialState: R._StateType,
        externalVariables: [AnySnapshotController],
        fsmVars: V,
        recorder: KR,
        ringlet: R,
        initialPreviousState: R._StateType,
        suspendedState: R._StateType?,
        suspendState: R._StateType,
        exitState: R._StateType
    ) {
        self.currentState = initialState
        self.exitState = exitState
        self.externalVariables = externalVariables
        self.fsmVars = fsmVars
        self.initialState = initialState
        self.initialPreviousState = initialPreviousState
        self.name = name
        self.previousState = initialPreviousState
        self.recorder = recorder
        self.ringlet = ringlet
        self.suspendedState = suspendedState
        self.suspendState = suspendState
    }

    public func clone() -> FiniteStateMachine<R, KR, V>{
        self.fsmVars.vars = self.fsmVars.vars.clone()
        var currentState = self.currentState
        currentState.transitions = self.currentState.transitions.map { $0.map { $0.clone() } }
        var fsm = FiniteStateMachine(
            self.name,
            initialState: self.initialState.clone(),
            externalVariables: self.externalVariables,
            fsmVars: self.fsmVars,
            recorder: self.recorder,
            ringlet: self.ringlet.clone(),
            initialPreviousState: self.initialPreviousState.clone(),
            suspendedState: self.suspendedState?.clone(),
            suspendState: self.suspendState.clone(),
            exitState: self.exitState.clone()
        )
        fsm.currentState = currentState
        fsm.previousState = self.previousState.clone()
        return fsm
    }

    public mutating func update(fromDictionary dictionary: [String: Any]) {
        self.currentState.update(fromDictionary: dictionary[self.currentState.name] as! [String: Any])
        self.fsmVars.vars.update(fromDictionary: dictionary["fsmVars"] as! [String: Any])
    }


}
