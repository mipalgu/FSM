/*
 * Whiteboard.swift
 * swiftfsm
 *
 * Created by Callum McColl on 12/12/2015.
 * Copyright © 2015 Callum McColl. All rights reserved.
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

public protocol WhiteboardType {
    /// required constructor for a default whiteboard
    init()
    
    /// return the number of known message types
    static var number_of_messages: Int32 { get }
    
    /// get a message of a given type
    func get<T>(msg: wb_types) -> T
    
    /// post a message of a given type to a given `wb_types` slot
    func post<T>(val: T, msg: wb_types)
}

/// Swift convenience wrapper around gusimplewhiteboard
public struct Whiteboard: WhiteboardType {
    /// pointer to the underlying C whiteboard implementation
    let wbd: UnsafeMutablePointer<gu_simple_whiteboard_descriptor>
    
    /// return ta pointer to the underlying C whiteboard infrastructure
    public var wb: UnsafeMutablePointer<gu_simple_whiteboard> {
        return wbd.pointee.wb
    }
    
    /// convenience class variable denoting the number of defined wb types
    public static var number_of_messages: Int32 { return GSW_NUM_TYPES_DEFINED }
    
    public init() {
        self.init(wbd: get_local_singleton_whiteboard())
    }

    public init(wbd: UnsafeMutablePointer<gu_simple_whiteboard_descriptor>) {
        self.wbd = wbd
    }
    
    /// get message template function
    public func get<T>(msg: wb_types) -> T {
        let msg: UnsafeMutablePointer<gu_simple_message> =
            gsw_current_message(wb, Int32(msg.rawValue))
        let msgp = UnsafePointer<T>(msg)
        return msgp.pointee
    }
    
    /// post message template function
    public func post<T>(val: T, msg: wb_types) {
        let msgno = Int32(msg.rawValue)
        let msgp = UnsafeMutablePointer<T>(gsw_next_message(wb, msgno))
        msgp?.pointee = val
        gsw_increment(wb, msgno)
    }
}
