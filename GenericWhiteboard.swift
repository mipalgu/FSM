/*
 * GenericWhiteboard.swift 
 * FSM 
 *
 * Created by Callum McColl on 19/03/2016.
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

public class GenericWhiteboard<T> {
    
    public typealias Message = T

    private let atomic: Bool
    private let msgType: wb_types
    private let notifySubscribers: Bool
    private var procured: Bool = false
    private let wb: Whiteboard

    public var currentIndex: UInt8 {
        get {
            return self.indexes[self.msgTypeOffset]
        } set {
            if (false == self.procure()) {
                return
            }
            self.indexes[self.msgTypeOffset] = (newValue % UInt8(generations))
            self.vacate()
        }
    }

    public var currentMessage: Message {
        get {
            return self.wb.get(msgType)
        } set {
            if (false == self.procure()) {
                return
            }
            self.messages[Int(self.currentIndex)] = newValue
            self.vacate()
        }
    }

    public var eventCount: UInt16 {
        get {
            return self.eventCounters[self.msgTypeOffset]
        } set {
            if (false == self.procure()) {
                return
            }
            self.eventCounters[self.msgTypeOffset] = newValue
            self.vacate()
        }
    }

    public var eventCounters: CArray<UInt16> {
        return CArray(
            first: &self.gsw.memory.event_counters.0,
            length: self.totalMessageTypes
        )
    }

    public var generations: Int {
        return Int(GU_SIMPLE_WHITEBOARD_GENERATIONS)
    }

    public var gsw: UnsafeMutablePointer<gu_simple_whiteboard> {
        return self.wb.wbd.memory.wb
    }

    public var indexes: CArray<UInt8> {
        return CArray(
            first: &self.gsw.memory.indexes.0,
            length: self.totalMessageTypes
        )
    }

    public var messages: CArray<Message> {
        let messages = CArray(
            first: &self.gsw.memory.messages.0,
            length: self.totalMessageTypes
        )
        let first: UnsafeMutablePointer<Message> = 
            withUnsafeMutablePointer(&messages[self.msgTypeOffset].0) {
                UnsafeMutablePointer<Message>($0)
            }
        return CArray(first: first, length: self.generations)
    }

    public var msgTypeOffset: Int {
        return Int(self.msgType.rawValue)
    }

    public var nextMessage: Message {
        get {
            return self.messages[Int(self.currentIndex) + 1 % self.generations]
        } set {
            if (false == self.procure()) {
                return
            }
            self.messages[Int(self.currentIndex + 1) % self.generations] =
                newValue
            self.vacate()
        }
    }

    public var numTypes: UInt16 {
        return self.gsw.memory.num_types
    }

    public var subscribed: UInt16 {
        return self.gsw.memory.subscribed
    }

    public var totalMessageTypes: Int {
        return Int(GSW_TOTAL_MESSAGE_TYPES)
    }

    public var version: UInt16 {
        return self.gsw.memory.version
    }

    public init(
        msgType: wb_types,
        wb: Whiteboard = Whiteboard(),
        atomic: Bool = true,
        notifySubscribers: Bool = true
    ) {
        self.atomic = atomic
        self.msgType = msgType
        self.notifySubscribers = notifySubscribers
        self.wb = wb
    }

    public func post(val: Message) {
        if (false == self.procure()) {
            return
        }
        self.wb.post(val, msg: self.msgType)
        self.eventCount += 1
        self.vacate()
    }

    public func procure() -> Bool {
        if (true == self.atomic && false == self.procured) {
            let sem = self.wb.wbd.memory.sem
            self.procured = 0 == gsw_procure(sem, GSW_SEM_PUTMSG)
            return self.procured
        }
        return true
    }

    public func vacate() -> Bool {
        if (true == self.procured) {
            let sem = self.wb.wbd.memory.sem
            return 0 == gsw_vacate(sem, GSW_SEM_PUTMSG)
        }
        return true
    }

}
