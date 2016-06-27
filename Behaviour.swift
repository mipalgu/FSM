/*
 * Behaviour.swift 
 * FSM 
 *
 * Created by Callum McColl on 11/03/2016.
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

/// Behaviours represent values that change in time.
///
/// Semantically behaviours are just functions of time:
///
///     Behaviour<T> = (Time) -> T
///
/// This allows us to ask what the value of a Behaviour is at a given time. 
///
/// - SeeAlso: `Time`
///
/// # Creating Behaviours
///
/// ## Converting To Behaviours
///
/// Any function of time can be turned into a Behaviour through the use of
/// `pure<T>(_:)`:
///
/// ```swift
/// let b: Behaviour<Int> = pure { (t: Time) -> Int in Int(t) }
/// ```
///
/// - SeeAlso: `pure(_:)`
///
/// ## Constants
///
/// You can define values that do not change using `always(_:)`:
///
/// ```swift
/// let b: Behaviour<Int> = always(5)
/// b.at(1)   // 5
/// b.at(100) // 5
/// ```
///
/// - SeeAlso: `always(_:)` 
/// - SeeAlso: `Behaviour.at`
///
/// # Working with Behaviours.
///
/// ## Arithmetic
///
/// In a few cases behaviours can be treated much like normal values.  For
/// instance we can modify numerical Behaviours as if they were normal values:
///
/// ```swift
/// let alwaysTwo: Behaviour<Int> = always(2)
/// let alwaysThree: Behaviour<Int> = always(3)
/// let alwaysFive: Behaviour<Int> = alwaysTwo + alwaysThree
/// ```
///
/// ## Comparisons
///
/// Like numerical arithmetic we are able to use logical comparisons on
/// behaviours.
///
/// ```swift
/// let alwaysFive: Behaviour<Int> = always(5)
/// let alternating: Behaviour<Int> = alwaysFive >>- { (val: Int) -> Behaviour<Int> in
///     pure { $0 % 2 == 0 ? val : val * 2 }
/// }
/// alternating.at(0) // 5
/// alternating.at(1) // 10
/// alternating.at(2) // 5
/// alternating.at(3) // 10
/// let switch: Behaviour<Bool> = alternating == alwaysFive
/// switch.at(0) // true
/// switch.at(1) // false
/// switch.at(2) // true
/// switch.at(3) // false
/// ```
///
/// However there are cases where this simple arithmetic is not enough.  For
/// instance how would you go about changing a value in a Behaviour at a
/// specific time?
///
/// - SeeAlso: `always(_:)`
/// - SeeAlso: `pure(_:)`
/// - SeeAlso: `>>-(_:, _:)`
///
/// ## Triggers
///
/// In order to modify the value of a Behaviour at a specific time you must use
/// a trigger.  Triggers are function that return a tuple.
///
/// ```swift
/// let t: (b: Behaviour<Int?>, m: (Int) -> Void) = trigger()
/// ```
///
/// As you can see the `trigger` function above creates a Behaviour that
/// contains an Int optional.  By using the modification function `m` you can
/// feed values into the Behaviour.  For example:
///
/// ```swift
/// let t: (b: Behaviour<Int?>, m: (Int) -> Void) = trigger()
/// t.b.at(0)   // nil
/// t.m(5)
/// t.m(6)
/// t.at(0)     // 5
/// t.at(1)     // 6
/// ```
///
/// - SeeAlso: `trigger()`
/// - SeeAlso: `trigger(_:)`
public struct Behaviour<T> {

    /// Extract a value at a specific time.
    ///
    /// - Parameter _: The time when you want the value.
    ///
    /// - Returns: The value.
    public let at: (Time) -> T

    private init(at: (Time) -> T) {
        self.at = at
    }

    /// Creates a new Behaviour where the value is the given function applied
    /// to the value at the given time.
    ///
    /// - Parameter f: The function to apply to the value.
    ///
    /// - Returns: The new Behaviour.
    public func map<U>(_ f: (T) -> U) -> Behaviour<U> {
        return pure { (t: Time) -> U in f(self.at(t)) }
    }

    /// Create a new Behaviour by applying the function within the given
    /// Behaviour at the given time to the value of the current Behaviour at the
    /// given time.
    ///
    /// - Parameter f: The Behaviour that contains all the functions to apply.
    ///
    /// - Returns: The new Behaviour.
    public func apply<U>(_ f: Behaviour<(T) -> U>) -> Behaviour<U> {
        return pure { (t: Time) -> U in f.at(t)(self.at(t)) }
    }

    /// Create a new Behaviour that is the result of applying the function to
    /// the value of the current Behaviour at a given time.
    ///
    /// - Parameter f: The function that creates the new Behaviour from a value.
    ///
    /// - Returns: The new Behaviour.
    public func flatMap<U>(_ f: (T) -> Behaviour<U>) -> Behaviour<U> {
        return pure { (t: Time) -> U in f(self.at(t)).at(t) }
    }

}

/// Create a Behaviour that never changes.
///
/// - Parameter value: The value that is constant in time.
///
/// - Returns: The new Behaviour that contains `value` for all values of `Time`.
///
/// - SeeAlso: Behaviour
public func always<T>(_ value: T) -> Behaviour<T> {
    return pure { (t: Time) -> T in value }
}

/// Lifts a function of time so that it becomes a `Behaviour`.
///
/// - Parameter f: The function of time.
///
/// - Returns: The new Behaviour.
///
/// - SeeAlso: `Behaviour`
/// - SeeAlso: `Time`
public func pure<T>(_ f: (Time) -> T) -> Behaviour<T> {
    return Behaviour(at: f)
}

/// Create a Behaviour<T> and a function to insert values into it.
///
/// - Returns: A tuple which contains:
///     - The Behaviour.
///     - A function that can be called to insert values into the Behaviour.
///
/// - Attention: The Behaviour that is created by this function uses an array to
/// store all the values.  If you do not need to access past values then you
/// should consider using a different trigger.
///
/// - SeeAlso: `trigger(_:)`
/// - SeeAlso: `Behaviour`
public func trigger<T>() -> (Behaviour<T?>, (T) -> Void) {
    var data: [T] = []
    var t: Time = Time.min
    return (
        pure { 
            let temp: Int = Int($0)
            return temp >= data.count || temp < 0 ? nil : data[temp] 
        },
        { 
            data.append($0)
            t = t + 1
        }
    )
}

/// Create a Behaviour that only remembers a certain amount of values.
///
/// - Parameter remember: The amount of values to remember.
///
/// - Returns: A tuple that contains:
///     - The Behaviour.
///     - A function that can be called to insert values into the Behaviour.
///
/// - SeeAlso: `Behaviour`
public func trigger<T>(remember: Int) -> (Behaviour<T?>, (T) -> Void) {
    var data: [T] = []
    data.reserveCapacity(remember)
    var t: Time = Time.min
    return (
        pure {
            if ($0 < 0 || $0 > t || ($0 == 0 && t == 0) || $0 < t - Time(remember)) {
                return nil
            }
            return data[$0 == 0 ? 0 : Int($0) % remember]
        },
        {
            data.insert($0, at: t == 0 ? 0 : Int(t) % remember)
            t = t + 1
        }
    )
}

public func <^>
    <T, U, S: Sequence where S.Iterator.Element == Behaviour<T>>
(f: ([T]) -> U, s: S) -> Behaviour<U> {
    return pure { (t: Time) -> U in f(s.map({ $0.at(t) })) }
}

public func <^> <T, U>(f: (T) -> U, b: Behaviour<T>) -> Behaviour<U> {
    return b.map(f)
}

public func <*> <T, U>(f: Behaviour<(T) -> U>, b: Behaviour<T>) -> Behaviour<U> {
    return b.apply(f)
}

public func >>- <T, U>(b: Behaviour<T>, f: (T) -> Behaviour<U>) -> Behaviour<U> {
    return b.flatMap(f) 
}

public func -<< <T, U>(f: (T) -> Behaviour<U>, b: Behaviour<T>) -> Behaviour<U> {
    return b.flatMap(f)
}

public func >-> <A, B, C>(f: (A) -> Behaviour<B>, g: (B) -> Behaviour<C>) -> (A) -> Behaviour<C> {
    return { (x: A) -> Behaviour<C> in f(x) >>- g }
}

public func <-< <A, B, C>(f: (B) -> Behaviour<C>, g: (A) -> Behaviour<B>) -> (A) -> Behaviour<C> {
    return { (x: A) -> Behaviour<C> in g(x) >>- f }
}

public func ==<T: Equatable>(
   lhs: Behaviour<T>,
   rhs: Behaviour<T>
) -> Behaviour<Bool> {
    return pure { (t: Time) -> Bool in lhs.at(t) == rhs.at(t) }
}

public func !=<T: Equatable>(
   lhs: Behaviour<T>,
   rhs: Behaviour<T>
) -> Behaviour<Bool> {
    return pure { (t: Time) -> Bool in lhs.at(t) != rhs.at(t) }
}

public func <<T: Comparable>(
   lhs: Behaviour<T>,
   rhs: Behaviour<T>
) -> Behaviour<Bool> {
    return pure { (t: Time) -> Bool in lhs.at(t) < rhs.at(t)}
}

public func <=<T: Comparable>(
   lhs: Behaviour<T>,
   rhs: Behaviour<T>
) -> Behaviour<Bool> {
    return pure { (t: Time) -> Bool in lhs.at(t) <= rhs.at(t) }
}

public func ><T: Comparable>(
   lhs: Behaviour<T>,
   rhs: Behaviour<T>
) -> Behaviour<Bool> {
    return pure { (t: Time) -> Bool in lhs.at(t) > rhs.at(t) }
}

public func >=<T: Comparable>(
   lhs: Behaviour<T>,
   rhs: Behaviour<T>
) -> Behaviour<Bool> {
    return pure { (t: Time) -> Bool in lhs.at(t) >= rhs.at(t) }
}

public func +<T: IntegerArithmetic>(
    lhs: Behaviour<T>,
    rhs: Behaviour<T>
) -> Behaviour<T> {
    return pure { (t: Time) -> T in lhs.at(t) + rhs.at(t) }
}

public func -<T: IntegerArithmetic>(
    lhs: Behaviour<T>,
    rhs: Behaviour<T>
) -> Behaviour<T> {
    return pure { (t: Time) -> T in lhs.at(t) - rhs.at(t) }
}

public func *<T: IntegerArithmetic>(
   lhs: Behaviour<T>,
   rhs: Behaviour<T>
) -> Behaviour<T> {
    return pure { (t: Time) -> T in lhs.at(t) * rhs.at(t) }    
}

public func /<T: IntegerArithmetic>(
   lhs: Behaviour<T>,
   rhs: Behaviour<T>
) -> Behaviour<T> {
    return pure { (t: Time) -> T in lhs.at(t) / rhs.at(t) }
}

public func %<T: IntegerArithmetic>(
   lhs: Behaviour<T>,
   rhs: Behaviour<T>
) -> Behaviour<T> {
    return pure { (t: Time) -> T in lhs.at(t) % rhs.at(t) }
}

public func +(
    lhs: Behaviour<String>,
    rhs: Behaviour<String>
) -> Behaviour<String> {
    return pure { (t: Time) -> String in lhs.at(t) + rhs.at(t) }
}
