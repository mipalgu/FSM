/*
 * FlattenedMetaArrangement.swift
 * swiftfsm
 *
 * Created by Callum McColl on 24/10/20.
 * Copyright © 2020 Callum McColl. All rights reserved.
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

#if os(macOS)
import Darwin
#else
import Glibc
#endif

public struct FlattenedMetaArrangement {
    
    public var name: String
    
    public var fsms: [String: FlattenedMetaFSM]
    
    public var rootFSMs: [String]
    
    public init(name: String, fsms: [String: FlattenedMetaFSM], rootFSMs: [String]) {
        self.name = name
        self.fsms = fsms
        self.rootFSMs = rootFSMs
    }
    
    public init(fromSharedLibrary path: String, factorySymbol symbolName: String = "make_Arrangement") throws {
        #if os(macOS)
        // Can the dylib be opened?
        if false == dlopen_preflight(path) {
            throw DynamicLoadingError.loadingError(message: String(cString: dlerror()))
        }
        #endif
        // Attempt to open the library.
        guard let handler = dlopen(path, RTLD_NOW | RTLD_LOCAL) else {
            throw DynamicLoadingError.loadingError(message: String(cString: dlerror()))
        }
        guard let symbol = dlsym(handler, symbolName) else {
            throw DynamicLoadingError.loadingError(message: String(cString: dlerror()))
        }
        let factoryFunc = unsafeBitCast(symbol, to: (@convention(c) (UnsafeRawPointer) -> Void).self)
        var arrangement = FlattenedMetaArrangement(name: "", fsms: [:], rootFSMs: [])
        var loaded: Bool = false
        let callback: (FlattenedMetaArrangement) -> Void = {
            arrangement = $0
            loaded = true
        }
        withUnsafePointer(to: callback) {
            factoryFunc(UnsafeRawPointer($0))
        }
        if !loaded {
            throw DynamicLoadingError.loadingError(message: "Called factory function, but did not store result.")
        }
        self = arrangement
    }
    
    public enum DynamicLoadingError: Error {
        
        case loadingError(message: String)
        
    }
    
}
