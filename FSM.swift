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
    initialState: State,
    initialPreviousState: State = EmptyState("_previous"),
    suspendedState: State? = nil,
    suspendState: State = EmptyState("_suspend"),
    exitState: State = EmptyState("_exit")
) -> AnyScheduleableFiniteStateMachine {
    dprint("1")
    if (true == KRIPKE) {
        return FSM(
            name,
            initialState: initialState,
            ringlet: KripkeMiPalRingletFactory.make(),
            initialPreviousState: initialPreviousState,
            suspendedState: suspendedState,
            suspendState: suspendState,
            exitState: exitState
        )
    }
    return FSM(
        name,
        initialState: initialState,
        ringlet: MiPalRingletFactory.make(),
        initialPreviousState: initialPreviousState,
        suspendedState: suspendedState,
        suspendState: suspendState,
        exitState: exitState
    )
}

public func FSM<G: GlobalVariablesContainer where G: Snapshotable>(
    _ name: String,
    initialState: State,
    globals: G,
    initialPreviousState: State = EmptyState("_previous"),
    suspendedState: State? = nil,
    suspendState: State = EmptyState("_suspend"),
    exitState: State = EmptyState("_exit")
) -> AnyScheduleableFiniteStateMachine {
    dprint("2")
    if (true == KRIPKE) {
        return FSM(
            name,
            initialState: initialState,
            ringlet: KripkeMiPalRinglet(
                globals: globals,
                fsmVars: EmptyVariables(),
                extractor: MirrorPropertyExtractor()
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
        ringlet: MiPalRinglet(vars: globals),
        initialPreviousState: initialPreviousState,
        suspendedState: suspendedState,
        suspendState: suspendState,
        exitState: exitState
    )
}

public func FSM<V: Variables>(
    _ name: String,
    initialState: State,
    fsmVars: V,
    initialPreviousState: State = EmptyState("_previous"),
    suspendedState: State? = nil,
    suspendState: State = EmptyState("_suspend"),
    exitState: State = EmptyState("_exit")
) -> AnyScheduleableFiniteStateMachine {
    dprint("3")
    if (true == KRIPKE) {
        return FSM(
            name,
            initialState: initialState,
            ringlet: KripkeMiPalRinglet(
                globals: EmptyGlobalVariablesContainer(),
                fsmVars: fsmVars,
                extractor: MirrorPropertyExtractor()
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
        ringlet: MiPalRingletFactory.make(),
        initialPreviousState: initialPreviousState,
        suspendedState: suspendedState,
        suspendState: suspendState,
        exitState: exitState
    )
}

public func FSM<
    G: GlobalVariablesContainer,
    V: Variables where G: Snapshotable
>(
    _ name: String,
    initialState: State,
    globals: G,
    fsmVars: V,
    initialPreviousState: State = EmptyState("_previous"),
    suspendedState: State? = nil,
    suspendState: State = EmptyState("_suspend"),
    exitState: State = EmptyState("_exit")
) -> AnyScheduleableFiniteStateMachine {
    dprint("4")
    if (true == KRIPKE) {
        return FSM(
            name,
            initialState: initialState,
            ringlet: KripkeMiPalRinglet(
                globals: globals,
                fsmVars: fsmVars,
                extractor: MirrorPropertyExtractor()
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
        ringlet: MiPalRinglet(vars: globals),
        initialPreviousState: initialPreviousState,
        suspendedState: suspendedState,
        suspendState: suspendState,
        exitState: exitState
    )
}

public func FSM<R: Ringlet where R._StateType == State>(
    _ name: String,
    initialState: State,
    ringlet: R,
    initialPreviousState: State = EmptyState("_previous"),
    suspendedState: State? = nil,
    suspendState: State = EmptyState("_suspend"),
    exitState: State = EmptyState("_exit")
) -> AnyScheduleableFiniteStateMachine {
    dprint("5")
    return AnyScheduleableFiniteStateMachine(
        FiniteStateMachine<R, EmptyVariables>(
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

public func FSM<R: KripkeRinglet where R._StateType == State>(
    _ name: String,
    initialState: State,
    ringlet: R,
    initialPreviousState: State = EmptyState("_previous"),
    suspendedState: State? = nil,
    suspendState: State = EmptyState("_suspend"),
    exitState: State = EmptyState("_exit")
) -> AnyScheduleableFiniteStateMachine {
    dprint("6")
    return AnyScheduleableFiniteStateMachine(
        KripkeFiniteStateMachine<R, EmptyVariables>(
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

public func FSM<R: Ringlet where R._StateType: Transitionable>(
    _ name: String,
    initialState: R._StateType,
    ringlet: R,
    initialPreviousState: R._StateType,
    suspendedState: R._StateType,
    suspendState: R._StateType,
    exitState: R._StateType
) -> AnyScheduleableFiniteStateMachine {
    dprint("7")
    return AnyScheduleableFiniteStateMachine(
        FiniteStateMachine<R, EmptyVariables>(
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

public func FSM<R: KripkeRinglet where R._StateType: Transitionable>(
    _ name: String,
    initialState: R._StateType,
    ringlet: R,
    initialPreviousState: R._StateType,
    suspendedState: R._StateType,
    suspendState: R._StateType,
    exitState: R._StateType
) -> AnyScheduleableFiniteStateMachine {
    dprint("8")
    return AnyScheduleableFiniteStateMachine(
        KripkeFiniteStateMachine<R, EmptyVariables>(
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
