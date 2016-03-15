/*
 * WhiteboardBehaviour.swift 
 * FSM 
 *
 * Created by Callum McColl on 12/03/2016.
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

public func trigger<T: GlobalVariables>(
    type: wb_types
) -> (Behaviour<T?>, (T) -> Void) {
    let wb: Whiteboard = Whiteboard()
    let sem: gsw_sema_t = wb.wbd.memory.sem
    let b: Behaviour<T?> = Behaviour { (t: Time) -> T? in
        guard t > 0 && 0 == gsw_vacate(sem, GSW_SEM_PUTMSG) else {
            return nil
        }
        // Get the event counter
        let temp: Time? =
            withUnsafePointer(&wb.wbd.memory.wb.memory.event_counters.0) {
                // Reference to first position in event_counters array.
                let p: UnsafeMutablePointer<UInt16> = 
                    UnsafeMutablePointer<UInt16>($0)
                // Reference to the value for the type we want.
                let p2: UnsafeMutablePointer<UInt16> = 
                    p.advancedBy(Int(type.rawValue))
                // Just in case.
                if (nil == p2) {
                    return nil
                }
                // Return the event count for our specific type.
                return Time(p2.memory)
            }
        print(temp)
        guard let eventCount: Time = temp else {
            gsw_vacate(sem, GSW_SEM_PUTMSG) 
            return nil
        }
        print("test")
        // Check if t is valid
        let generations: Time = Time(GU_SIMPLE_WHITEBOARD_GENERATIONS)
        guard eventCount > generations && t >= eventCount - generations else {
            gsw_vacate(sem, GSW_SEM_PUTMSG) 
            return nil
        }
        guard t <= eventCount else {
            gsw_vacate(sem, GSW_SEM_PUTMSG)
            return nil
        }
        print("hello")
        return nil
        /*let i: Int = Int(t % generations)
        let val: UnsafeMutablePointer<T> = (wb.wbd.memory.messages[type.rawValue][i])
        if (nil == val) {
            gsw_vacate(sem, GSW_SEM_PUTMSG) 
            return nil
        }
        let v: T = val.memory
        gsw_vacate(sem, GSW_SEM_PUTMSG) 
        return v*/
    }
    let f: (T) -> Void = { wb.post($0, msg: type) }
    return (b, f)
}
