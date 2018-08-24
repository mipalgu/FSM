/*
 * ConvertibleCArray.swift 
 * FSM 
 *
 * Created by Callum McColl on 25/03/2016.
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
 *  Provides a wrapper for C arrays that contain a certain type but need to be
 *  converted to a second type.
 *
 *  For instance a use case for this struct is with the gusimplewhiteboard.  The
 *  individual messages in the whiteboard are stored as gu_simple_messages, but
 *  the developer would like to cast these to the message that they are using.
 *  By using a ConvertibleCArray we can convert from the gu_simple_message to a
 *  wb_point for instance.
 *
 *  This struct uses an underlying `CArray` which actually stores the values.
 *  Therefore this struct works much like a proxy where it delegates most of its
 *  implementation to the underlying `CArray`.  Where this struct actually
 *  provides a difference in the implementation from `CArray` is when 
 *  retrieving/modifying the elements in the array.  When retrieving an element
 *  from the array, this struct does delegate to the underlying array, however
 *  the struct then converts the retrieved value to `To`.  When modifying
 *  elements this struct does the reverse where it first converts the new
 *  element to `From` before delegating to the underlying `CArray`.
 */
public struct ConvertibleCArray<From, To> {

    /**
     *  The element that we are converting to.
     */
    public typealias Element = To

    /**
     *  The array that actually stores the `From` data.
     */
    internal var arr: CArray<From>

    /**
     *  Create the Convertible CArray from a CArray.
     *
     *  - Parameter arr: The CArray that contains the elements that we are
     *  attempting to convert.
     */
    public init(arr: CArray<From>) {
        self.arr = arr
    }

}

/**
 *  Turn the ConvertibleCArray in a Sequence.
 *
 *  This allows us to use the function that sequence gives us, such as map and
 *  filter.
 */
extension ConvertibleCArray: Sequence {

    /**
     *  The iterator that iterates over all of the elements and converts them.
     */
    public typealias Iterator = AnyIterator<Element>

    /**
     *  Create the iterator that iterates over all the elements of the array.
     *
     *  The iterator retrieves each element from the underlying CArray and then
     *  converts each element.
     *
     *  - Returns: The newly created iterator.
     */
    public func makeIterator() -> AnyIterator<Element> {
        if 0 == self.arr.count {
            return AnyIterator { nil }
        }
        var pos: Int = 0
        return AnyIterator {
            if pos >= self.arr.length || nil == self.arr.p {
                return nil
            }
            let v: Element = UnsafeRawPointer(
                self.arr.p!.advanced(by: pos)
            ).bindMemory(to: Element.self, capacity: 1).pointee
            pos += 1
            return v
        }
    }
}

/**
 *  Turn the ConvertibleCArray into a Collection.
 *
 *  This allows us to retrieve/modify elements from their position in the array.
 */
extension ConvertibleCArray: Collection {

    /**
     *  Specifies that we use ints to retrieve/modify elements.
     */
    public typealias Index = CArray<From>.Index

    /**
     *  We start at element 0.
     */
    public var startIndex: Int {
        return self.arr.startIndex
    }

    /**
     *  The last position is the length of the array - 1.
     */
    public var endIndex: Int {
        return self.arr.endIndex
    }

    /**
     *  Access the element at a specific position.
     *
     *  This will retrieve the element at `i` from the underlying CArray and
     *  then convert the element.
     *
     *  - Parameter i: The position of the element in the array to access.
     *
     *  - Complexity: O(1).
     *
     *  - Precondition: `startIndex` <= `i` < `endIndex`
     */
    public subscript(i: Int) -> Element {
        get {
            return UnsafeRawPointer(self.arr.p!.advanced(by: i)).bindMemory(
                to: Element.self,
                capacity: 1
            ).pointee
        } set {
            var newValue: Element = newValue
            withUnsafeMutablePointer(to: &newValue) {
                self.arr[i] = UnsafeRawPointer($0).bindMemory(
                    to: From.self,
                    capacity: 1
                ).pointee
            }
        }
    }

    /**
     *  Returns the position immediately after the given index.
     *
     *  - Parameter i: A valid index of the `ConvertibleCArray`.
     *
     *  - Returns: The index value immediately after `i`.
     */
    public func index(after i: Index) -> Index {
        return self.arr.index(after: i)
    }

}
