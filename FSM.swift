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

public func FSM<G: GlobalVariablesContainer>(
    _ name: String,
    initialState: MiPalState,
    globals: G,
    initialPreviousState: MiPalState = EmptyMiPalState("_previous"),
    suspendedState: MiPalState? = nil,
    suspendState: MiPalState = EmptyMiPalState("_suspend"),
    exitState: MiPalState = EmptyMiPalState("_exit")
) -> AnyScheduleableFiniteStateMachine where G: Snapshotable {
    if (true == KRIPKE) {
        return FSM(
            name,
            initialState: initialState,
            ringlet: KripkeMiPalRinglet(
                globals: globals,
                fsmVars: SimpleVariablesContainer(vars: EmptyVariables()),
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
            globals: globals,
            previousState: initialPreviousState
        ),
        initialPreviousState: initialPreviousState,
        suspendedState: suspendedState,
        suspendState: suspendState,
        exitState: exitState
    )
}

public func FSM<V: Variables>(
    _ name: String,
    initialState: MiPalState,
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
                globals: EmptyGlobalVariablesContainer(),
                fsmVars: SimpleVariablesContainer(vars: fsmVars),
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
        ringlet: MiPalRingletFactory.make(
            previousState: initialPreviousState
        ),
        initialPreviousState: initialPreviousState,
        suspendedState: suspendedState,
        suspendState: suspendState,
        exitState: exitState
    )
}

public func FSM<G: GlobalVariablesContainer,V: Variables>(
    _ name: String,
    initialState: MiPalState,
    globals: G,
    fsmVars: V,
    initialPreviousState: MiPalState = EmptyMiPalState("_previous"),
    suspendedState: MiPalState? = nil,
    suspendState: MiPalState = EmptyMiPalState("_suspend"),
    exitState: MiPalState = EmptyMiPalState("_exit")
) -> AnyScheduleableFiniteStateMachine where G: Snapshotable {
    if (true == KRIPKE) {
        return FSM(
            name,
            initialState: initialState,
            ringlet: KripkeMiPalRinglet(
                globals: globals,
                fsmVars: SimpleVariablesContainer(vars: fsmVars),
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
            globals: globals,
            previousState: initialPreviousState
        ),
        initialPreviousState: initialPreviousState,
        suspendedState: suspendedState,
        suspendState: suspendState,
        exitState: exitState
    )
}

public func FSM<R: Ringlet>(
    _ name: String,
    initialState: MiPalState,
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
            ringlet: ringlet,
            initialPreviousState: initialPreviousState,
            suspendedState: suspendedState,
            suspendState: suspendState,
            exitState: exitState
        )
    )
}

public func FSM<R: KripkeRinglet>(
    _ name: String,
    initialState: MiPalState,
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
            ringlet: ringlet,
            generator: HashTableKripkeRingletKripkeStructureGeneratorFactory().make(),
            initialPreviousState: initialPreviousState,
            suspendedState: suspendedState,
            suspendState: suspendState,
            exitState: exitState
        )
    )
}


public func FSM<FSM: FiniteStateMachineType>(
    _ fsm: FSM
) -> AnyScheduleableFiniteStateMachine where
    FSM: StateExecuter,
    FSM: Finishable,
    FSM: Resumeable,
    FSM: SnapshotContainer
{
    return AnyScheduleableFiniteStateMachine(fsm)
}

public func FSMS<FSM: FiniteStateMachineType>(
    _ fsms: FSM ...
) -> [AnyScheduleableFiniteStateMachine] where
    FSM: StateExecuter,
    FSM: Finishable,
    FSM: Resumeable,
    FSM: SnapshotContainer
{
    return fsms.map { AnyScheduleableFiniteStateMachine($0) }
}
