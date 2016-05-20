/*
 * Transition.swift
 * swiftfsm
 *
 * Created by Callum McColl on 11/08/2015.
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
 *  A transition which allows the current state to change from one state to the
 *  next.
 *  
 *  Transitions may have to meet certain conditions which is why the
 *  canTransition property is a Bool indicating whether or not this specific
 *  transition is allowed.
 */

//public typealias Transition = () -> State? 

public protocol TransitionType {
    
    associatedtype Target

    var canTransition: () -> Bool { get }
    var target: Target { get }

}

public struct Transition<S: State>: TransitionType {

    public typealias Target = S

    public let canTransition: () -> Bool
    public let target: Target

    public init(_ target: Target, _ canTransition: () -> Bool = { true }) {
        self.canTransition = canTransition
        self.target = target
    }

    public func map<S2: State>(_ f: @noescape (S) -> S2) -> Transition<S2> {
        return Transition<S2>(f(self.target), self.canTransition)
    }

    public func apply<S2: State>(_ t: Transition<S2>) -> Transition<S> {
        return Transition(self.target, t.canTransition)
    }

    public func flatMap<S2: State>(
        _ f: @noescape (S) -> Transition<S2>
    ) -> Transition<S2> {
        return f(self.target)
    }

}

public func <^> <
    T: State, U: State
>(_ f: @noescape (T) -> U, a: Transition<T>) -> Transition<U> {
    return a.map(f)
}

public func <*> <
    T: State, U: State
>(_ f: Transition<U>, a: Transition<T>) -> Transition<T> {
    return a.apply(f)
}

public func >>- <
    T: State, U: State
>(a: Transition<T>, _ f: @noescape (T) -> Transition<U>) -> Transition<U> {
    return a.flatMap(f)
}

/*
public protocol Transition {
    
    /**
     *  The state which we are transitioning to.
     */
    var target: State { get }
    
    /**
     *  Do we meet all of the conditions to transition?
     */
    var canTransition: Bool { get }
    
}*/
