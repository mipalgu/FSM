/*
 * ClockConstraint.swift
 * KripkeStructure
 *
 * Created by Callum McColl on 14/5/20.
 * Copyright © 2020 Callum McColl. All rights reserved.
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

public typealias ClockConstraint = Constraint<UInt>

public enum Constraint<T: Comparable> {
    
    case lessThan(value: T)
    case lessThanEqual(value: T)
    case equal(value: T)
    case notEqual(value: T)
    case greaterThan(value: T)
    case greaterThanEqual(value: T)
    indirect case and(lhs: Constraint<T>, rhs: Constraint<T>)
    indirect case or(lhs: Constraint<T>, rhs: Constraint<T>)
    indirect case not(value: Constraint<T>)
    
    var inverse: Constraint<T> {
        switch self {
        case .lessThan(let value):
            return .greaterThanEqual(value: value)
        case .lessThanEqual(let value):
            return .greaterThan(value: value)
        case .equal(let value):
            return .notEqual(value: value)
        case .notEqual(let value):
            return .equal(value: value)
        case .greaterThan(let value):
            return .lessThanEqual(value: value)
        case .greaterThanEqual(let value):
            return .lessThan(value: value)
        case .and(let lhs, let rhs):
            return .or(lhs: lhs.inverse, rhs: rhs.inverse)
        case .or(let lhs, let rhs):
            return .and(lhs: lhs.inverse, rhs: rhs.inverse)
        case .not(let value):
            return value
        }
    }
    
    var reduced: Constraint<T> {
        switch self {
        case .not(let value):
            return value.inverse
        default:
            return self
        }
    }
    
}

extension Constraint: Equatable {}
extension Constraint: Hashable where T: Hashable {}

extension Constraint: CustomStringConvertible {
    
    public var description: String {
        return self.expressionString(referencing: "")
    }
    
    public func expressionString(referencing label: String) -> String {
        switch self.reduced {
        case .lessThan(let value):
            return "\(label) < \(value)"
        case .lessThanEqual(let value):
            return "\(label) <= \(value)"
        case .equal(let value):
            return "\(label) == \(value)"
        case .notEqual(let value):
            return "\(label) != \(value)"
        case .greaterThan(let value):
            return "\(label) > \(value)"
        case .greaterThanEqual(let value):
            return "\(label) >= \(value)"
        case .and(let lhs, let rhs):
            return "(\(lhs.expressionString(referencing: label))) && (\(rhs.expressionString(referencing: label)))"
        case .or(let lhs, let rhs):
            return "(\(lhs.expressionString(referencing: label))) && (\(rhs.expressionString(referencing: label)))"
        case .not(let constraint):
            return "!(\(constraint.expressionString(referencing: label)))"
        }
    }
    
}
