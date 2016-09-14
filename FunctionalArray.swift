/*
 * FunctionalArray.swift 
 * FSM 
 *
 * Created by Callum McColl on 15/02/2016.
 * 
 * Copyright (c) 2014 thoughtbot, inc.
 *  
 * MIT License
 *
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files (the
 * "Software"), to deal in the Software without restriction, including
 * without limitation the rights to use, copy, modify, merge, publish,
 * distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so, subject to
 * the following conditions:
 *  
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 * LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 * OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 * WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

public func -<< <T, U>(f: (T) -> U?, a: [T]) -> [U] {
    return a.flatMap(f)

}

public func >>- <T, U>(a: [T], f: (T) -> U?) -> [U] {
    return a.flatMap(f)
}

/**
 *  Wrap a value in a minimal context of `[]`
 *
 *  - Parameter a: A value of type `T`
 *
 *  - Returns: The provided value wrapped in an array
 */
public func pure<T>(a: T) -> [T] {
    return [a]
}
