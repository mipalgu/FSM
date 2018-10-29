/*
 * FSMType.swift
 * swiftfsm
 *
 * Created by Callum McColl on 29/10/18.
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

import FSM
import Functional
import KripkeStructure
import ModelChecking
import Utilities

public enum FSMType {
    
    public var asParameterisedFiniteStateMachine: AnyParameterisedFiniteStateMachine? {
        switch self {
        case .parameterisedFSM(let fsm):
            return fsm
        case .scheduleableFSM(let fsm):
            return fsm.asParameterisedFiniteStateMachine
        }
    }
    
    public var asScheduleableFiniteStateMachine: AnyScheduleableFiniteStateMachine {
        switch self {
        case .parameterisedFSM(let fsm):
            return fsm.asScheduleableFiniteStateMachine
        case .scheduleableFSM(let fsm):
            return fsm
        }
    }
    
    case parameterisedFSM(AnyParameterisedFiniteStateMachine)
    
    case scheduleableFSM(AnyScheduleableFiniteStateMachine)
    
}

extension FSMType: Equatable {}

public func == (lhs: FSMType, rhs: FSMType) -> Bool {
    switch lhs {
    case .parameterisedFSM(let lfsm):
        switch rhs {
        case .parameterisedFSM(let rfsm):
            return lfsm == rfsm
        default:
            return false
        }
    case .scheduleableFSM(let lfsm):
        switch rhs {
        case .scheduleableFSM(let rfsm):
            return lfsm == rfsm
        default:
            return false
        }
    }
}

extension FSMType: ConvertibleToScheduleableFiniteStateMachine {
    
    public typealias _StateType = AnyState
    
    public var currentState: AnyState {
        get {
            switch self {
            case .parameterisedFSM(let fsm):
                return fsm.currentState
            case .scheduleableFSM(let fsm):
                return fsm.currentState
            }
        } set {}
    }
    
    public var externalVariables: [AnySnapshotController] {
        get {
            switch self {
            case .parameterisedFSM(let fsm):
                return fsm.externalVariables
            case .scheduleableFSM(let fsm):
                return fsm.externalVariables
            }
        } set {
            switch self {
            case .parameterisedFSM(var fsm):
                fsm.externalVariables = newValue
                self = .parameterisedFSM(fsm)
            case .scheduleableFSM(var fsm):
                fsm.externalVariables = newValue
                self = .scheduleableFSM(fsm)
            }
        }
    }
    
    public var hasFinished: Bool {
        switch self {
        case .parameterisedFSM(let fsm):
            return fsm.hasFinished
        case .scheduleableFSM(let fsm):
            return fsm.hasFinished
        }
    }
    
    public var initialState: AnyState {
        switch self {
        case .parameterisedFSM(let fsm):
            return fsm.initialState
        case .scheduleableFSM(let fsm):
            return fsm.initialState
        }
    }
    
    public var isSuspended: Bool {
        switch self {
        case .parameterisedFSM(let fsm):
            return fsm.isSuspended
        case .scheduleableFSM(let fsm):
            return fsm.isSuspended
        }
    }
    
    public var name: String {
        switch self {
        case .parameterisedFSM(let fsm):
            return fsm.name
        case .scheduleableFSM(let fsm):
            return fsm.name
        }
    }
    
    public var submachines: [AnyScheduleableFiniteStateMachine] {
        switch self {
        case .parameterisedFSM(let fsm):
            return fsm.submachines
        case .scheduleableFSM(let fsm):
            return fsm.submachines
        }
    }
    
    public func clone() -> FSMType {
        switch self {
        case .parameterisedFSM(let fsm):
            return .parameterisedFSM(fsm.clone())
        case .scheduleableFSM(let fsm):
            return .scheduleableFSM(fsm.clone())
        }
    }
    
    public mutating func next() {
        switch self {
        case .parameterisedFSM(let fsm):
            fsm.next()
        case .scheduleableFSM(let fsm):
            fsm.next()
        }
    }
    
    public mutating func suspend() {
        switch self {
        case .parameterisedFSM(let fsm):
            fsm.suspend()
        case .scheduleableFSM(let fsm):
            fsm.suspend()
        }
    }
    
    public mutating func saveSnapshot() {
        switch self {
        case .parameterisedFSM(let fsm):
            fsm.saveSnapshot()
        case .scheduleableFSM(let fsm):
            fsm.saveSnapshot()
        }
    }
    
    public mutating func takeSnapshot() {
        switch self {
        case .parameterisedFSM(let fsm):
            fsm.takeSnapshot()
        case .scheduleableFSM(let fsm):
            fsm.takeSnapshot()
        }
    }
    
}
