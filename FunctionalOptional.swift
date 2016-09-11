/*
 * FuntionalOptional.swift 
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

/**
 *  Map a function over an optional value.
 *
 *  - If the value is `.none`, the function will not be evaluated and this will
 *  return `.none`.
 *
 *  - If the value is `.some`, the function will be applied to the unwrapped
 *  value.
 *
 *  - Parameter f: A transformation function from type `T` to type `U`.
 *
 *  - Parameter a: A value of type `Optional<T>`.
 *
 *  - Returns: A value of type `Optional<U>`.
 */
public func <^> <T, U>(f: (T) -> U, a: T?) -> U? {
    return a.map(f)
}

/**
 *  Apply an optional function to an optional value.
 *
 *  - If either the value or the function are `.none`, the function will not be
 *  evaluated and this will return `.none`.
 *
 *  - If both the value and the function are `.some`, the function will be
 *  applied to the unwrapped value.
 *
 * - Parameter f: An optional transformation function from type `T` to type `U`.
 *
 * - Parameter a: A value of type `Optional<T>`.
 *
 * - Returns: A value of type `Optional<U>`.
 */
public func <*> <T, U>(f: ((T) -> U)?, a: T?) -> U? {
    return a.apply(f)
}

/**
 *  FlatMap a function over an optional value (left associative).
 *
 *  - If the value is `.none`, the function will not be evaluated and this will
 *  return `.none`.
 * 
 *  - If the value is `.some`, the function will be applied to the unwrapped
 *  value.
 *
 * - Parameter f: A transformation function from type `T` to type `Optional<U>`.
 *
 * - Parameter a: A value of type `Optional<T>`.
 *
 * - Returns: A value of type `Optional<U>`.
 */
public func >>- <T, U>(a: T?, f: (T) -> U?) -> U? {
    return a.flatMap(f)
}

/**
 *  FlatMap a function over an optional value (right associative).
 *
 *  - If the value is `.none`, the function will not be evaluated and this will
 *  return `.none`.
 *
 * - If the value is `.some`, the function will be applied to the unwrapped
 *  value.
 *
 * - Parameter a: A value of type `Optional<T>`.
 *
 * - Parameter f: A transformation function from type `T` to type `Optional<U>`.
 *
 * - Returns: A value of type `Optional<U>`.
 */
public func -<< <T, U>(f: (T) -> U?, a: T?) -> U? {
    return a.flatMap(f)
}

/**
 *  Compose two functions that produce optional values, from left to right.
 *
 *  - If the result of the first function is `.none`, the second function will
 *  not be inoked and this will return `.none`.
 *
 *  - If the result of the first function is `.some`, the value is unwrapped
 *  and passed to the second function which may return `.none`.
 *
 *  - Parameter f: A transformation function from type `A` to type
 *  `Optional<B>`.
 *
 *  - Parameter g: A transformation function from type `B` to type
 *  `Optional<C>`.
 *
 * - Returns: A function from type `A` to type `Optional<C>`.
 */
public func >-> <A, B, C>(
    f: @escaping (A) -> B?,
    g: @escaping (B) -> C?
) -> (A) -> C? {
    return { x in f(x) >>- g }
}

/**
 *  Compose two functions that produce optional values, from right to left.
 *
 *  - If the result of the first function is `.none`, the second function will
 *  not be invoked and this will return `.none`.
 *
 *  - If the result of the first function is `.some`, the value is unwrapped and
 *  passed to the second function which may return `.none`.
 *
 *  - Parameter f: A transformation function from type `B` to type
 *  `Optional<C>`.
 *
 *  - Parameter g: A transformation function from type `A` to type
 *  `Optional<B>`.
 *
 *  - Returns: A function from type `A` to type `Optional<C>`.
 */
public func <-< <A, B, C>(
    f: @escaping (B) -> C?,
    g: @escaping (A) -> B?
) -> (A) -> C? {
    return { x in g(x) >>- f }
}

/**
 *  Wrap a value in a minimal context of `.some`.
 *
 *  - Parameter a: A value of type `T`.
 *
 *  - Returns: The provided value wrapped in `.some`.
 */
public func pure<T>(a: T) -> T? {
    return .some(a)
}

public extension Optional {

    /**
     *  Apply an optional function to `self`.
     *
     *  - If either self or the function are `.none`, the function will not be
     *  evaluated and this will return `.none`.
     *
     *  - If both self and the function are `.some`, the function will be
     *  applied to the unwrapped value.
     *
     *  - Parameter f: An optional transformation function from type `Wrapped`
     *  to type `U`.
     *
     *  - Returns: A value of type `Optional<U>`.
     */
    func apply<U>(_ f: ((Wrapped) -> U)?) -> U? {
            return f.flatMap { self.map($0) }
    }
}
