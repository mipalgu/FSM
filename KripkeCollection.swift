/*
 * KripkeCollection.swift 
 * FSM 
 *
 * Created by Callum McColl on 18/03/2016.
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

public protocol KripkeCollection {

    func toArray() -> [Any]

}

extension SequenceType where Self: KripkeCollection {

    public func toArray() -> [Any] {
        return self.map { $0 as Any }
    }

}

extension AnyGenerator: KripkeCollection {}

extension AnySequence: KripkeCollection {}

extension FlattenBidirectionalCollection: KripkeCollection {}

extension FlattenCollection: KripkeCollection {}

extension UnsafeMutableBufferPointer: KripkeCollection {}

extension MutableSlice: KripkeCollection {}

extension ArraySlice: KripkeCollection {}

extension ContiguousArray: KripkeCollection {}

extension Array: KripkeCollection {}

extension Range: KripkeCollection {}

extension String.CharacterView: KripkeCollection {}

extension String.UnicodeScalarView: KripkeCollection {}

extension Repeat: KripkeCollection {}

extension Set: KripkeCollection {}

extension Slice: KripkeCollection {}

extension String.UTF16View: KripkeCollection {}

extension String.UTF8View: KripkeCollection {}

//extension UnicodeScalar.UTF16View: KripkeCollection {}

extension UnsafeBufferPointer: KripkeCollection {}

extension ReverseCollection: KripkeCollection {}

extension ReverseRandomAccessCollection: KripkeCollection {}

extension AnyRandomAccessCollection: KripkeCollection {}

extension AnyBidirectionalCollection: KripkeCollection {}

extension AnyForwardCollection: KripkeCollection {}

extension CollectionOfOne: KripkeCollection {}

extension Dictionary: KripkeCollection {}

extension DictionaryLiteral: KripkeCollection {}

extension EmptyCollection: KripkeCollection {}

extension EmptyGenerator: KripkeCollection {}

extension EnumerateGenerator: KripkeCollection {}

extension EnumerateSequence: KripkeCollection {}

extension LazyCollection: KripkeCollection {}

extension LazyFilterCollection: KripkeCollection {}

extension LazyMapCollection: KripkeCollection {}

extension FlattenGenerator: KripkeCollection {}

extension FlattenSequence: KripkeCollection {}

extension GeneratorOfOne: KripkeCollection {}

extension GeneratorSequence: KripkeCollection {}

extension IndexingGenerator: KripkeCollection {}

extension JoinSequence: KripkeCollection {}

extension LazyFilterGenerator: KripkeCollection {}

extension LazyMapGenerator: KripkeCollection {}

//extension LazyFilterSequence: KripkeCollecton {}

extension LazySequence: KripkeCollection {}

extension PermutationGenerator: KripkeCollection {}

extension RangeGenerator: KripkeCollection {}

extension StrideThrough: KripkeCollection {}

extension StrideTo: KripkeCollection {}

extension UnsafeBufferPointerGenerator: KripkeCollection {}

extension Zip2Sequence: KripkeCollection {}
