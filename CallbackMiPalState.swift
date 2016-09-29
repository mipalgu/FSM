/*
 * CallbackMiPalState.swift
 * swiftfsm
 *
 * Created by Callum McColl on 23/08/2015.
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

/**
 *  Provides a way for developers to pass in the onEntry, main and onExit
 *  methods when initializing a state so that they can more easily create simple
 *  states.
 *
 *  This class cannot be subclasses.
 */
public final class CallbackMiPalState: MiPalState {
    
    /**
     *  The actual onEntry implementation.
     */
    public let _onEntry: () -> Void
    
    /**
     *  The actual main implementation.
     */
    public let _main: () -> Void
    
    /**
     *  The actual onExit implementation.
     */
    public let _onExit: () -> Void
    
    public init(
        _ name: String,
        transitions: [Transition<MiPalState>] = [],
        onEntry: @escaping () -> Void = {},
        main: @escaping () -> Void = {},
        onExit: @escaping () -> Void = {}
    ) {
        self._onEntry = onEntry
        self._main = main
        self._onExit = onExit
        super.init(name, transitions: transitions)
    }
    
    /**
     *  This method simply calls `_onEntry`.
     *
     *  This method cannot be overrided as all `CallbackState`s must use the 
     *  `_onEntry` property instead.
     */
    public override final func onEntry() {
        self._onEntry()
    }
    
    /**
     *  This method simply calls `_main`.
     *
     *  This method cannot be overrided as all `CallbackState`s must use the
     *  `_main` property instead.
     */
    public override final func main() {
        self._main()
    }
    
    /**
     *  This method simply calls `_onExit`.
     *
     *  This method cannot be overrided as all `CallbackState`s must use the
     *  `_onExit` property instead.
     */
    public override final func onExit() {
        self._onExit()
    }
    
    public override final func clone(
        transitions: [Transition<MiPalState>]
    ) -> CallbackMiPalState {
        return CallbackMiPalState(
            self.name,
            transitions: transitions,
            onEntry: self._onEntry,
            main: self._main,
            onExit: self._onExit
        )
    }

}
