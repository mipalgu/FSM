/*
 * FunctionalOperators.swift 
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

precedencegroup LeftFunctionalPrecedence {
    associativity: left
    higherThan: CastingPrecedence
}

precedencegroup RightFunctionalPrecedence {
    associativity: right
    higherThan: CastingPrecedence
}

/**
 *  Map a function over a value with context.
 *
 *  Expected function type: `(a -> b) -> f a -> f b`.
 */
infix operator <^> : LeftFunctionalPrecedence

/**
 *  Apply a function with context to a value with context.
 *
 *  Expected function type: `f (a -> b) -> f a -> f b`.
 */
infix operator <*> : LeftFunctionalPrecedence

/**
 *  Map a function over a value with context and flatten the result.
 *
 *  Expected function type: `m a -> (a -> m b) -> m b`.
 */
infix operator >>- : LeftFunctionalPrecedence

/**
 *  Map a function over a value with context and flatten the result.
 *
 *  Expected function type: `(a -> m b) -> m a -> m b`.
 */
infix operator -<< : RightFunctionalPrecedence

/**
 *  Compose two functions that produce results in a context, from left to right,
 *  returning a result in that context.
 *
 *  Expected function type: `(a -> m b) -> (b -> m c) -> a -> m c`.
 */
infix operator >-> : LeftFunctionalPrecedence

/**
 *  Compose two functions that produce results in a context, from right to left,
 *  returning a result in that context.
 *
 *  Like `>->`, but with the arguments flipped.
 *
 *  Expected function type: `(b -> m c) -> (a -> m b) -> a -> m c`.
 */
infix operator <-< : RightFunctionalPrecedence
