/*
 * globals.swift
 * swiftfsm
 *
 * Created by Callum McColl on 8/09/2015.
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

import Functional
import KripkeStructure

/**
 *  Set to true when debugging is turned on.
 */
public var DEBUG: Bool = false

/**
 *  Set to true when generate `KripkeStructure`s.
 */
public var KRIPKE: Bool = false

/**
 *  Set to true when all Finite State Machines should be stopped.
 */
public var STOP: Bool = false

private var factories = Factories()

/**
 *  Add an `FSMArrayFactory` onto the `Factories` `Stack`.
 *
 *  - Parameter _: The `FSMArrayFactory`.
 */
public func addFactory(_ f: @escaping FSMArrayFactory) {
    factories.push(f)
}

public func cast<S1, S2, T>(transitions: [Transition<S1, T>]) -> [Transition<S2, T>] {
    return transitions.map(cast)
}

public func cast<S1, S2, T>(_ transition: Transition<S1, T>) -> Transition<S2, T> {
    return Transition<S2, T>(transition.target) {
        guard let state = $0 as? S1 else {
            fatalError("Unable to cast \($0) to \(S1.self)")
        }
        return transition.canTransition(state)
    }
}

/**
 *  A convenience function which only prints when `DEBUG` is true.
 */
public func dprint(
    _ items: Any ...,
    separator: String = " ",
    terminator: String = "\n"
) {
    if false == DEBUG {
        return
    }
    _ = items.map {
        print($0, separator: separator, terminator: terminator)
    }
}

/**
 *  A convenience function which only prints when `DEBUG` is true.
 */
public func dprint<Target: TextOutputStream>(
    _ items: Any ...,
    separator: String = " ",
    terminator: String = "\n",
    toStream output: inout Target
) {
    if false == DEBUG {
        return
    }
    _ = items.map {
        print(
            $0,
            separator: separator,
            terminator: terminator,
            to: &output
        )
    }
}

/**
 *  Retrieve the number of `FSMArrayFactory`s that are on the `Factories`
 *  `Stack`.
 *  
 *  - Returns: The number of `FSMArrayFactory`s that are on the `Factories`
 *  `Stack`.
 */
public func getFactoryCount() -> Int {
    return factories.count
}

/**
 *  Retrieve the top most `FSMArrayFactory` from the `Factories` `Stack`.
 *
 *  - Postcondition: The top most `FSMArrayFactory` is removed from the
 *  `Factories` `Stack`.
 *
 *  - Returns: The retrieved `FSMArrayFactory` or nil if the `Factories` `Stack`
 *  was empty.
 */
public func getLastFactory() -> FSMArrayFactory? {
    if true == factories.isEmpty {
        return nil
    }
    return factories.pop()
}

/**
 *  Sets `STOP` to true.
 */
public func stopAll() {
    STOP = true
}
