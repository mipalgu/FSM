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

/**
 * map a function over a value with context
 *
 * Expected function type: `(a -> b) -> f a -> f b`
 */
infix operator <^> {
    associativity left

    // Same precedence as the equality operator (`==`)
    precedence 130
}

/**
 * apply a function with context to a value with context
 *
 * Expected function type: `f (a -> b) -> f a -> f b`
 */
infix operator <*> {
    associativity left

    // Same precedence as the equality operator (`==`)
    precedence 130
}

/**
 * map a function over a value with context and flatten the result
 *
 * Expected function type: `m a -> (a -> m b) -> m b`
 */
infix operator >>- {
    associativity left

    // Lower precedence than the logical comparison operators
    // (`&&` and `||`), but higher precedence than the assignment
    // operator (`=`)
    precedence 100
}

/**
 * map a function over a value with context and flatten the result
 *
 * Expected function type: `(a -> m b) -> m a -> m b`
 */
infix operator -<< {
    associativity right

    // Lower precedence than the logical comparison operators
    // (`&&` and `||`), but higher precedence than the assignment
    // operator (`=`)
    precedence 100
}

/**
 * compose two functions that produce results in a context, from left to right,
 * returning a result in that context
 *
 * Expected function type: `(a -> m b) -> (b -> m c) -> a -> m c`
 */
infix operator >-> {
    associativity right

    // Same precedence as `>>-` and `-<<`.
    precedence 100
}

/**
 * compose two functions that produce results in a context, from right to left,
 * returning a result in that context
 *
 * like `>->`, but with the arguments flipped
 *
 * Expected function type: `(b -> m c) -> (a -> m b) -> a -> m c`
 */
infix operator <-< {
    associativity right

    // Same precedence as `>>-` and `-<<`.
    precedence 100
}