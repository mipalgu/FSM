/*
 * FSM.swift 
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

import KripkeStructure

/**
 *  Create an `AnyScheduleableFiniteStateMachine` that uses `MiPalState`s.
 *
 *  The underlying `FiniteStateMachineType` will either be `FiniteStateMachine`
 *  or `KripkeFiniteStateMachine` depending on the value of `KRIPKE`.
 *
 *  The `Ringlet` that is used will either be a `MiPalRinglet` or a
 *  `KripkeMiPalRinglet` depending on the value of `KRIPKE`.
 *
 *  - Parameter name: The name of the `FiniteStateMachineType`.
 *
 *  - Parameter initialState: The initial state of the `FiniteStateMachineType`.
 *
 *  - Parameter initialPreviousState: The initial previous state.  This
 *  satisfies requirements from `OptimizedStateExecuter`.
 *
 *  - Parameter suspendedState: When this is not nil, the
 *  `FiniteStateMachineType` is suspended.  Upon resuming `currentState` will be
 *  set to this state.  This partially satisfies requirements from
 *  `Suspendable`.
 *
 *  - Parameter suspendState: When the `FiniteStateMachineType` is suspended, 
 *  `currentState` is set to this state.  This partially satisfies requirements
 *  from `Suspendable`.
 *
 *  - Parameter exitState: When `exit()` is called, `currentState` is set to
 *  this state.  This satisfies requirements from `ExitableState`.
 *
 *  - SeeAlso: `AnyScheduleableFiniteStateMachine`
 *  - SeeAlso: `FiniteStateMachineType`
 *  - SeeAlso: `FiniteStateMachine`
 *  - SeeAlso: `KRIPKE`
 *  - SeeAlso: `KripkeFiniteStateMachine`
 *  - SeeAlso: `KripkeMiPalRinglet`
 *  - SeeAlso: `MiPalRinglet`
 *  - SeeAlso: `Ringlet`
 */
public func FSM(
    _ name: String,
    initialState: MiPalState,
    initialPreviousState: MiPalState = EmptyMiPalState("_previous"),
    suspendedState: MiPalState? = nil,
    suspendState: MiPalState = EmptyMiPalState("_suspend"),
    exitState: MiPalState = EmptyMiPalState("_exit")
) -> AnyScheduleableFiniteStateMachine {
    if (true == KRIPKE) {
        return FSM(
            name,
            initialState: initialState,
            ringlet: KripkeMiPalRingletFactory.make(
                previousState: initialPreviousState
            ),
            initialPreviousState: initialPreviousState,
            suspendedState: suspendedState,
            suspendState: suspendState,
            exitState: exitState
        )
    }
    return FSM(
        name,
        initialState: initialState,
        ringlet: MiPalRingletFactory.make(
            previousState: initialPreviousState
        ),
        initialPreviousState: initialPreviousState,
        suspendedState: suspendedState,
        suspendState: suspendState,
        exitState: exitState
    )
}

/**
 *  Create an `AnyScheduleableFiniteStateMachine` that uses `MiPalState`s.
 *
 *  The underlying `FiniteStateMachineType` will either be `FiniteStateMachine`
 *  or `KripkeFiniteStateMachine` depending on the value of `KRIPKE`.
 *
 *  The `Ringlet` that is used will either be a `MiPalRinglet` or a
 *  `KripkeMiPalRinglet` depending on the value of `KRIPKE`.
 *
 *  - Parameter name: The name of the `FiniteStateMachineType`.
 *
 *  - Parameter initialState: The initial state of the `FiniteStateMachineType`.
 *
 *  - Parameter initialPreviousState: The initial previous state.  This
 *  satisfies requirements from `OptimizedStateExecuter`.
 *
 *  - Parameter externalVariables: The `ExternalVariables`.
 *
 *  - Parameter suspendedState: When this is not nil, the
 *  `FiniteStateMachineType` is suspended.  Upon resuming `currentState` will be
 *  set to this state.  This partially satisfies requirements from
 *  `Suspendable`.
 *
 *  - Parameter suspendState: When the `FiniteStateMachineType` is suspended, 
 *  `currentState` is set to this state.  This partially satisfies requirements
 *  from `Suspendable`.
 *
 *  - Parameter exitState: When `exit()` is called, `currentState` is set to
 *  this state.  This satisfies requirements from `ExitableState`.
 *
 *  - SeeAlso: `AnyScheduleableFiniteStateMachine`
 *  - SeeAlso: `FiniteStateMachineType`
 *  - SeeAlso: `FiniteStateMachine`
 *  - SeeAlso: `KRIPKE`
 *  - SeeAlso: `KripkeFiniteStateMachine`
 *  - SeeAlso: `KripkeMiPalRinglet`
 *  - SeeAlso: `MiPalRinglet`
 *  - SeeAlso: `Ringlet`
 */
public func FSM<EV: ExternalVariablesContainer>(
    _ name: String,
    initialState: MiPalState,
    externalVariables: EV,
    initialPreviousState: MiPalState = EmptyMiPalState("_previous"),
    suspendedState: MiPalState? = nil,
    suspendState: MiPalState = EmptyMiPalState("_suspend"),
    exitState: MiPalState = EmptyMiPalState("_exit")
) -> AnyScheduleableFiniteStateMachine where EV: Snapshotable {
    return FSM(
        name,
        initialState: initialState,
        externalVariables: [AnySnapshotController(externalVariables)],
        fsmVars: SimpleVariablesContainer(vars: EmptyVariables()),
        initialPreviousState: initialPreviousState,
        suspendedState: suspendedState,
        suspendState: suspendState,
        exitState: exitState
    )
}

/**
 *  Create an `AnyScheduleableFiniteStateMachine` that uses `MiPalState`s.
 *
 *  The underlying `FiniteStateMachineType` will either be `FiniteStateMachine`
 *  or `KripkeFiniteStateMachine` depending on the value of `KRIPKE`.
 *
 *  The `Ringlet` that is used will either be a `MiPalRinglet` or a
 *  `KripkeMiPalRinglet` depending on the value of `KRIPKE`.
 *
 *  - Parameter name: The name of the `FiniteStateMachineType`.
 *
 *  - Parameter initialState: The initial state of the `FiniteStateMachineType`.
 *
 *  - Parameter initialPreviousState: The initial previous state.  This
 *  satisfies requirements from `OptimizedStateExecuter`.
 *
 *  - Parameter fsmVars: The FSM local variables.
 *
 *  - Parameter suspendedState: When this is not nil, the
 *  `FiniteStateMachineType` is suspended.  Upon resuming `currentState` will be
 *  set to this state.  This partially satisfies requirements from
 *  `Suspendable`.
 *
 *  - Parameter suspendState: When the `FiniteStateMachineType` is suspended, 
 *  `currentState` is set to this state.  This partially satisfies requirements
 *  from `Suspendable`.
 *
 *  - Parameter exitState: When `exit()` is called, `currentState` is set to
 *  this state.  This satisfies requirements from `ExitableState`.
 *
 *  - Returns: A new instance of `AnyScheduleableFiniteStateMachine`.
 *
 *  - SeeAlso: `AnyScheduleableFiniteStateMachine`
 *  - SeeAlso: `FiniteStateMachineType`
 *  - SeeAlso: `FiniteStateMachine`
 *  - SeeAlso: `KRIPKE`
 *  - SeeAlso: `KripkeFiniteStateMachine`
 *  - SeeAlso: `KripkeMiPalRinglet`
 *  - SeeAlso: `MiPalRinglet`
 *  - SeeAlso: `Ringlet`
 */
public func FSM<V: VariablesContainer>(
    _ name: String,
    initialState: MiPalState,
    fsmVars: V,
    initialPreviousState: MiPalState = EmptyMiPalState("_previous"),
    suspendedState: MiPalState? = nil,
    suspendState: MiPalState = EmptyMiPalState("_suspend"),
    exitState: MiPalState = EmptyMiPalState("_exit")
) -> AnyScheduleableFiniteStateMachine {
    return FSM(
        name,
        initialState: initialState,
        externalVariables: [],
        fsmVars: fsmVars,
        initialPreviousState: initialPreviousState,
        suspendedState: suspendedState,
        suspendState: suspendState,
        exitState: exitState
    )
}

/**
 *  Create an `AnyScheduleableFiniteStateMachine` that uses `MiPalState`s.
 *
 *  The underlying `FiniteStateMachineType` will either be `FiniteStateMachine`
 *  or `KripkeFiniteStateMachine` depending on the value of `KRIPKE`.
 *
 *  The `Ringlet` that is used will either be a `MiPalRinglet` or a
 *  `KripkeMiPalRinglet` depending on the value of `KRIPKE`.
 *
 *  - Parameter name: The name of the `FiniteStateMachineType`.
 *
 *  - Parameter initialState: The initial state of the `FiniteStateMachineType`.
 *
 *  - Parameter initialPreviousState: The initial previous state.  This
 *  satisfies requirements from `OptimizedStateExecuter`.
 *
 *  - Parameter externalVariables: The `ExternalVariables`.
 *
 *  - Parameter fsmVars: The FSM local variables.
 *
 *  - Parameter suspendedState: When this is not nil, the
 *  `FiniteStateMachineType` is suspended.  Upon resuming `currentState` will be
 *  set to this state.  This partially satisfies requirements from
 *  `Suspendable`.
 *
 *  - Parameter suspendState: When the `FiniteStateMachineType` is suspended, 
 *  `currentState` is set to this state.  This partially satisfies requirements
 *  from `Suspendable`.
 *
 *  - Parameter exitState: When `exit()` is called, `currentState` is set to
 *  this state.  This satisfies requirements from `ExitableState`.
 *
 *  - Returns: A new instance of `AnyScheduleableFiniteStateMachine`.
 *
 *  - SeeAlso: `AnyScheduleableFiniteStateMachine`
 *  - SeeAlso: `FiniteStateMachineType`
 *  - SeeAlso: `FiniteStateMachine`
 *  - SeeAlso: `KRIPKE`
 *  - SeeAlso: `KripkeFiniteStateMachine`
 *  - SeeAlso: `KripkeMiPalRinglet`
 *  - SeeAlso: `MiPalRinglet`
 *  - SeeAlso: `Ringlet`
 */
public func FSM<EV: ExternalVariablesContainer, V: VariablesContainer>(
    _ name: String,
    initialState: MiPalState,
    externalVariables: EV,
    fsmVars: V,
    initialPreviousState: MiPalState = EmptyMiPalState("_previous"),
    suspendedState: MiPalState? = nil,
    suspendState: MiPalState = EmptyMiPalState("_suspend"),
    exitState: MiPalState = EmptyMiPalState("_exit")
) -> AnyScheduleableFiniteStateMachine where EV: Snapshotable {
    return FSM(
        name,
        initialState: initialState,
        externalVariables: [AnySnapshotController(externalVariables)],
        fsmVars: fsmVars,
        initialPreviousState: initialPreviousState,
        suspendedState: suspendedState,
        suspendState: suspendState,
        exitState: exitState
    )
}

public func FSM<V: VariablesContainer>(
    _ name: String,
    initialState: MiPalState,
    externalVariables: [AnySnapshotController],
    fsmVars: V,
    initialPreviousState: MiPalState = EmptyMiPalState("_previous"),
    suspendedState: MiPalState? = nil,
    suspendState: MiPalState = EmptyMiPalState("_suspend"),
    exitState: MiPalState = EmptyMiPalState("_exit")
) -> AnyScheduleableFiniteStateMachine {
    if (true == KRIPKE) {
        return FSM(
            name,
            initialState: initialState,
            ringlet: KripkeMiPalRinglet(
                externalVariables: externalVariables,
                fsmVars: fsmVars,
                extractor: MirrorPropertyExtractor(),
                previousState: initialPreviousState
            ),
            initialPreviousState: initialPreviousState,
            suspendedState: suspendedState,
            suspendState: suspendState,
            exitState: exitState
        )
    }
    return FSM(
        name,
        initialState: initialState,
        ringlet: MiPalRinglet(
            externalVariables: externalVariables,
            previousState: initialPreviousState
        ),
        initialPreviousState: initialPreviousState,
        suspendedState: suspendedState,
        suspendState: suspendState,
        exitState: exitState
    )
}

/**
 *  Create an `AnyScheduleableFiniteStateMachine` that uses `MiPalState`s.
 *
 *  The underlying `FiniteStateMachineType` is `FiniteStateMachine`.
 *
 *  - Parameter name: The name of the `FiniteStateMachineType`.
 *
 *  - Parameter initialState: The initial state of the `FiniteStateMachineType`.
 *
 *  - Parameter initialPreviousState: The initial previous state.  This
 *  satisfies requirements from `OptimizedStateExecuter`.
 *
 *  - Parameter ringlet: The `Ringlet` to use to execute the `MiPalState`s.
 *  `Ringlet._StateType` must equal `MiPalState`.
 *
 *  - Parameter suspendedState: When this is not nil, the
 *  `FiniteStateMachineType` is suspended.  Upon resuming `currentState` will be
 *  set to this state.  This partially satisfies requirements from
 *  `Suspendable`.
 *
 *  - Parameter suspendState: When the `FiniteStateMachineType` is suspended, 
 *  `currentState` is set to this state.  This partially satisfies requirements
 *  from `Suspendable`.
 *
 *  - Parameter exitState: When `exit()` is called, `currentState` is set to
 *  this state.  This satisfies requirements from `ExitableState`.
 *
 *  - Returns: A new instance of `AnyScheduleableFiniteStateMachine`.
 *
 *  - SeeAlso: `AnyScheduleableFiniteStateMachine`
 *  - SeeAlso: `FiniteStateMachineType`
 *  - SeeAlso: `FiniteStateMachine`
 *  - SeeAlso: `Ringlet`
 */
public func FSM<R: Ringlet>(
    _ name: String,
    initialState: MiPalState,
    externalVariables: [AnySnapshotController] = [],
    ringlet: R,
    initialPreviousState: MiPalState = EmptyMiPalState("_previous"),
    suspendedState: MiPalState? = nil,
    suspendState: MiPalState = EmptyMiPalState("_suspend"),
    exitState: MiPalState = EmptyMiPalState("_exit")
) -> AnyScheduleableFiniteStateMachine where R._StateType == MiPalState {
    return AnyScheduleableFiniteStateMachine(
        FiniteStateMachine<R>(
            name,
            initialState: initialState,
            externalVariables: externalVariables,
            ringlet: ringlet,
            initialPreviousState: initialPreviousState,
            suspendedState: suspendedState,
            suspendState: suspendState,
            exitState: exitState
        )
    )
}

/**
 *  Create an `AnyScheduleableFiniteStateMachine` that uses `MiPalState`s.
 *
 *  The underlying `FiniteStateMachineType` is `KripkeFiniteStateMachine`.
 *
 *  - Parameter name: The name of the `FiniteStateMachineType`.
 *
 *  - Parameter initialState: The initial state of the `FiniteStateMachineType`.
 *
 *  - Parameter initialPreviousState: The initial previous state.  This
 *  satisfies requirements from `OptimizedStateExecuter`.
 *
 *  - Parameter ringlet: The `KripkeRinglet` to use to execute the
 *  `MiPalState`s.  `Ringlet._StateType` must equal `MiPalState`.
 *
 *  - Parameter suspendedState: When this is not nil, the
 *  `FiniteStateMachineType` is suspended.  Upon resuming `currentState` will be
 *  set to this state.  This partially satisfies requirements from
 *  `Suspendable`.
 *
 *  - Parameter suspendState: When the `FiniteStateMachineType` is suspended, 
 *  `currentState` is set to this state.  This partially satisfies requirements
 *  from `Suspendable`.
 *
 *  - Parameter exitState: When `exit()` is called, `currentState` is set to
 *  this state.  This satisfies requirements from `ExitableState`.
 *
 *  - Returns: A new instance of `AnyScheduleableFiniteStateMachine`.
 *
 *  - SeeAlso: `AnyScheduleableFiniteStateMachine`
 *  - SeeAlso: `FiniteStateMachineType`
 *  - SeeAlso: `KripkeFiniteStateMachine`
 *  - SeeAlso: `KripkeRinglet`
 */
public func FSM<R: KripkeRinglet>(
    _ name: String,
    initialState: MiPalState,
    externalVariables: [AnySnapshotController] = [],
    ringlet: R,
    initialPreviousState: MiPalState = EmptyMiPalState("_previous"),
    suspendedState: MiPalState? = nil,
    suspendState: MiPalState = EmptyMiPalState("_suspend"),
    exitState: MiPalState = EmptyMiPalState("_exit")
) -> AnyScheduleableFiniteStateMachine where R._StateType == MiPalState {
    return AnyScheduleableFiniteStateMachine(
        KripkeFiniteStateMachine(
            name,
            initialState: initialState,
            externalVariables: externalVariables,
            ringlet: ringlet,
            generator: HashTableKripkeRingletKripkeStructureGeneratorFactory().make(),
            initialPreviousState: initialPreviousState,
            suspendedState: suspendedState,
            suspendState: suspendState,
            exitState: exitState
        )
    )
}

public func MachineFSM<R: KripkeRinglet>(
    _ name: String,
    initialState: R._StateType,
    externalVariables: [AnySnapshotController] = [],
    ringlet: R,
    initialPreviousState: R._StateType,
    suspendedState: R._StateType? = nil,
    suspendState: R._StateType,
    exitState: R._StateType
) -> AnyScheduleableFiniteStateMachine where
    R._StateType: Transitionable,
    R._StateType._TransitionType == Transition<R._StateType, R._StateType>,
    R._StateType: KripkeVariablesModifier
{
    return AnyScheduleableFiniteStateMachine(
        KripkeFiniteStateMachine(
            name,
            initialState: initialState,
            externalVariables: externalVariables,
            ringlet: ringlet,
            generator: HashTableKripkeRingletKripkeStructureGeneratorFactory().make(),
            initialPreviousState: initialPreviousState,
            suspendedState: suspendedState,
            suspendState: suspendState,
            exitState: exitState
        )
    )
}


/**
 *  Converts a `FiniteStateMachineType` that is capable of being scheduled, to
 *  an `AnyScheduleableFiniteStateMachine`.
 *
 *  - Attention: This function just supplies some syntactic sugar, you can of
 *  course use the `AnyScheduleableFiniteStateMachine` constructor to achieve
 *  the same effect.
 *
 *  - Parameter fsm: The `FiniteStateMachineType` to convert.
 *
 *  - Returns: A new instance of `AnyScheduleableFiniteStateMachine`.
 *
 *  - SeeAlso: `AnyScheduleableFiniteStateMachine`
 *  - SeeAlso: `FiniteStateMachineType`
 */
public func FSM<FSM: FiniteStateMachineType>(
    _ fsm: FSM
) -> AnyScheduleableFiniteStateMachine where
    FSM: StateExecuter,
    FSM: Exitable,
    FSM: Finishable,
    FSM: KripkeStructureGenerator,
    FSM: Restartable,
    FSM: Resumeable,
    FSM: Snapshotable
{
    return AnyScheduleableFiniteStateMachine(fsm)
}

/**
 *  Converts an array of `FiniteStateMachineType`s that are capable of being
 *  scheduled, to an array of `AnyScheduleableFiniteStateMachine`s.
 *
 *  - Attention: This function just supplies some syntactic sugar, you can of
 *  course use the `AnyScheduleableFiniteStateMachine` constructor on each
 *  `FiniteStateMachineType` to achieve the same effect.
 *
 *  - Parameters fsms: The array of `FiniteStateMachineType`s to convert.
 *
 *  - Returns: An array of `AnyScheduleableFiniteStateMachine`s.
 *
 *  - SeeAlso: `AnyScheduleableFiniteStateMachine`
 *  - SeeAlso: `FiniteStateMachineType`
 */
public func FSMS<FSM: FiniteStateMachineType>(
    _ fsms: FSM ...
) -> [AnyScheduleableFiniteStateMachine] where
    FSM: StateExecuter,
    FSM: Exitable,
    FSM: Finishable,
    FSM: KripkeStructureGenerator,
    FSM: Restartable,
    FSM: Resumeable,
    FSM: Snapshotable
{
    return fsms.map { AnyScheduleableFiniteStateMachine($0) }
}
