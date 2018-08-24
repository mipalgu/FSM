/*
 * Factories.swift
 * swiftfsm
 *
 * Created by Callum McColl on 24/09/2015.
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

import FSM
import Utilities

/**
 *  A stack of `FSMArrayFactory`s.
 *
 *  Uses an underlying `Stack` of `FSMArrayFactory`s.  This struct therefore
 *  delegates most of it's implementation to the underlying stack.
 *
 *  The underlying stack `factories` is static and a getter/setter has been
 *  provided.  This therefore makes this struct a monostate where the underlying
 *  stack is shared between each instance of Factories.
 */
public struct Factories {

    private static var factories: Stack<FSMArrayFactory> = Stack<FSMArrayFactory>()

    /**
     *  Provides access to the underlying `factories` `Stack`.
     */
    public private(set) var factories: Stack<FSMArrayFactory> {
        get {
            return Factories.factories
        } set {
            Factories.factories = newValue
        }
    }

    /**
     *  The number of factories within the `Stack`.
     */
    public var count: Int {
        return self.factories.count
    }

    /**
     *  Is the `Stack` empty?
     */
    public var isEmpty: Bool {
        return self.factories.isEmpty
    }

    public init() {}

    /**
     *  Clear the `Stack` of all elements.
     */
    public mutating func clear() {
        self.factories.clear()
    }

    /**
     *  Retrieve the element that was added last to the `Stack`.
     *
     *  If the stack is empty then nil is returned.
     *
     *  - Returns: The latest element on the stack or .None if the stack is
     *  empty.
     */
    public func peek() -> FSMArrayFactory? {
        return self.factories.peek()
    }

    /**
     *  Retrieve the element that was added last to the `Stack`.
     *
     *  - Precondition: The `Stack` is not empty.
     *
     *  - Postcondition: The element is removed from the `Stack`.
     *
     *  - Returns: The latest element on the `Stack`.
     */
    public mutating func pop() -> FSMArrayFactory {
        return self.factories.pop()
    }

    /**
     *  Add an element to the stack.
     *
     *  - Parameter newElement: The new element to add to the stack.
     */
    public mutating func push(_ newElement: @escaping FSMArrayFactory) {
        self.factories.push(newElement)
    }

}

/**
 *  Make Factories a Sequence.
 *
 *  This lets you iterate through the factories using for loops, and gives
 *  access to higher order functions such as map and filter.
 */
extension Factories: Sequence {

    /**
     *  Factories contain FSMArrayFactory elements.
     */
    public typealias Element = FSMArrayFactory

    /**
     *  Factories is its own Iterator.
     */
    public typealias Iterator = Factories

    /**
     *  Just returns self.
     *
     *  - Returns: self.
     */
    public func makeIterator() -> Iterator {
        return self
    }

}

/**
 *  Make Factories conform to the IteratorProtocol..
 *
 *  This allows Factories to become its own `Iterator`.
 */
extension Factories: IteratorProtocol {

    /**
     *  Returns the next element on the stack.
     *
     *  - Warning: Once returned the element is removed from the stack.
     *
     *  - Returns: The last element that was added to the stack.
     */
    public mutating func next() -> Element? {
        if nil == self.peek() {
            return nil
        }
        return self.pop()
    }

}
