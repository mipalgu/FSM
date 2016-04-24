/*
 * WhiteboardCollection.swift 
 * FSM 
 *
 * Created by Callum McColl on 16/01/2016.
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

public struct WhiteboardCollection<T: GlobalVariables>:
    GlobalVariablesCollection
{

    public typealias Element = T
    public typealias Iterator = AnyIterator<T>

    private let type: wb_types
    private let wb: Whiteboard

    public init(type: wb_types, wb: Whiteboard) {
        self.type = type
        self.wb = wb
    }

    public func makeIterator() -> AnyIterator<T> {
        let type: Int32 = Int32(self.type.rawValue)
        let bufferLength: Int = Int(GU_SIMPLE_WHITEBOARD_GENERATIONS) 
        let sem: gsw_sema_t = self.wb.wbd.pointee.sem
        // Stop allowing others to modify the whiteboard.
        guard 0 == gsw_procure(sem, GSW_SEM_PUTMSG) else {
            return AnyIterator { nil }
        }
        let data: [T] = getData(wb: self.wb.wb, type: type, length: bufferLength)
        // Allow others to modify the whiteboard again.
        guard 0 == gsw_vacate(sem, GSW_SEM_PUTMSG) else {
            return AnyIterator { nil }
        }
        var i: Int = 0 
        return AnyIterator {
            if (i >= bufferLength) {
                return nil
            }
            let j = i
            i = i + 1
            return data[j]
        }
    }

    private func getData(
        wb: UnsafeMutablePointer<gu_simple_whiteboard>,
        type: Int32,
        length: Int
    ) -> [T] {
        var arr: [T] = []
        for _ in 0 ..< length {
            gsw_increment(wb, type)
            arr.append(
                UnsafeMutablePointer<T>(gsw_current_message(wb, type)).pointee
            )
        }
        return arr.reversed()
    }

    public func get() -> T {
        return self.wb.get(msg: self.type)
    }

    public func post(val: T) {
        self.wb.post(val: val, msg: self.type)
    }

}
