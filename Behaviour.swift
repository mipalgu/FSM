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

public struct Behaviour<T> {

    public let at: (Time) -> T

    private init(at: (Time) -> T) {
        self.at = at
    }

    public func map<U>(_ f: (T) -> U) -> Behaviour<U> {
        return pure { (t: Time) -> U in f(self.at(t)) }
    }

    public func apply<U>(_ f: Behaviour<(T) -> U>) -> Behaviour<U> {
        return pure { (t: Time) -> U in f.at(t)(self.at(t)) }
    }

    public func flatMap<U>(_ f: (T) -> Behaviour<U>) -> Behaviour<U> {
        return pure { (t: Time) -> U in f(self.at(t)).at(t) }
    }

}

public func always<T>(_ value: T) -> Behaviour<T> {
    return pure { (t: Time) -> T in value }
}

public func pure<T>(_ f: (Time) -> T) -> Behaviour<T> {
    return Behaviour(at: f)
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
