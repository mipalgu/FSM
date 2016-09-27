/*
 * Spinners.swift 
 * FSM 
 *
 * Created by Callum McColl on 27/09/2016.
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

public struct Spinners {

    public typealias Spinner<T> = (T) -> T?

    let bool: Spinner<Bool> = {true == $0 ? nil : true }

    let int: Spinner<Int> = { Int.max == $0 ? nil : $0.advanced(by: 1) }

    let int8: Spinner<Int8> = { Int8.max == $0 ? nil : $0.advanced(by: 1) }

    let int16: Spinner<Int16> = { Int16.max == $0 ? nil : $0.advanced(by: 1) }

    let int32: Spinner<Int32> = { Int32.max == $0 ? nil : $0.advanced(by: 1) }

    let int64: Spinner<Int64> = { Int64.max == $0 ? nil : $0.advanced(by: 1) }

    let uint: Spinner<UInt> = { UInt.max == $0 ? nil : $0.advanced(by: 1) }

    let uint8: Spinner<UInt8> = { UInt8.max == $0 ? nil : $0.advanced(by: 1) }

    let uint16: Spinner<UInt16> = { UInt16.max == $0 ? nil : $0.advanced(by: 1) }

    let uint32: Spinner<UInt32> = { UInt32.max == $0 ? nil : $0.advanced(by: 1) }

    let uint64: Spinner<UInt64> = { UInt64.max == $0 ? nil : $0.advanced(by: 1) }

    let float: Spinner<Float> = {
        if ($0 == Float.infinity) {
            return Float.nan
        }
        if ($0 == Float.nan) {
            return nil
        }
        return $0.nextUp
    }
    
    let float80: Spinner<Float80> = {
        if (Float80.infinity == $0) {
            return Float80.nan
        }
        if (Float80.nan == $0) {
            return nil
        }
        return $0.nextUp
    }

    let double: Spinner<Double> = {
        if (Double.infinity == $0) {
            return Double.nan
        }
        if (Double.nan == $0) {
            return nil
        }
        return $0.nextUp
    }

    let nilSpinner: Spinner<Any> = { _ -> Any? in nil }

}
