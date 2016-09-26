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

    public typealias Spinner = (Any) -> Any?

    let int: Spinner = {
        let num = $0 as! Int
        return Int.max == num ? nil : num.advanced(by: 1)
    }

    let int8: Spinner = {
        let num = $0 as! Int8
        return num == Int8.max ? nil : num.advanced(by: 1)
    }

    let int16: Spinner = {
        let num = $0 as! Int16
        return num == Int16.max ? nil : num.advanced(by: 1)
    }

    let int32: Spinner = {
        let num = $0 as! Int32
        return num == Int32.max ? nil : num.advanced(by: 1)
    }

    let int64: Spinner = {
        let num = $0 as! Int64
        return num == Int64.max ? nil : num.advanced(by: 1)
    }

    let uint: Spinner = {
        let num = $0 as! UInt
        return UInt.max == num ? nil : num.advanced(by: 1)
    }

    let uint8: Spinner = {
        let num = $0 as! UInt8
        return UInt8.max == num ? nil : num.advanced(by: 1)
    }

    let uint16: Spinner = {
        let num = $0 as! UInt16
        return UInt16.max == num ? nil : num.advanced(by: 1)
    }

    let uint32: Spinner = {
        let num = $0 as! UInt32
        return UInt32.max == num ? nil : num.advanced(by: 1)
    }

    let uint64: Spinner = {
        let num = $0 as! UInt64
        return UInt64.max == num ? nil : num.advanced(by: 1)
    }

    let float: Spinner = {
        let num = $0 as! Float
        if (num == Float.infinity) {
            return Float.nan
        }
        if (num == Float.nan) {
            return nil
        }
        return num.nextUp
    }
    
    let float80: Spinner = {
        let num = $0 as! Float80
        if (Float80.infinity == num) {
            return Float80.nan
        }
        if (Float80.nan == num) {
            return nil
        }
        return num.nextUp
    }

    let double: Spinner = {
        let num = $0 as! Double
        if (Double.infinity == num) {
            return Double.nan
        }
        if (Double.nan == num) {
            return nil
        }
        return num.nextUp
    }

    let nilSpinner: Spinner = { _ -> Any? in
        return nil
    }

}
