/*
 * MultipleExternalsSpinnerConstructor.swift 
 * FSM 
 *
 * Created by Callum McColl on 10/06/2017.
 * Copyright © 2017 Callum McColl. All rights reserved.
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

import FSM
import KripkeStructure

public final class MultipleExternalsSpinnerConstructor<Constructor: ExternalsSpinnerConstructorType>:
    MultipleExternalsSpinnerConstructorType
{

    private let constructor: Constructor

    public init(constructor: Constructor) {
        self.constructor = constructor
    }

    // swiftlint:disable large_tuple
    public func makeSpinner(
        forExternals data: [ExternalVariablesVerificationData]
    ) -> () -> [(AnySnapshotController, KripkeStatePropertyList)]? {
        if true == data.isEmpty {
            return self.makeEmptySpinner()
        }
        var externalSpinners = data.map {
            self.constructor.makeSpinner(
                fromExternalVariables: $0.externalVariables,
                defaultValues: $0.defaultValues,
                spinners: $0.spinners
            )
        }
        var latest: [(AnySnapshotController, KripkeStatePropertyList)] = data.map {
            var new = $0.externalVariables
            new.val = $0.externalVariables.create(fromDictionary: self.convert(from: $0.defaultValues))
            return (new, $0.defaultValues)
        }
        return { () -> [(AnySnapshotController, KripkeStatePropertyList)]? in
            guard let newItems = self.nextItem(inSpinners: &externalSpinners, usingData: data) else {
                return nil
            }
            for (newItem, ps, index) in newItems {
                latest[index] = (newItem, ps)
            }
            return latest
        }
    }
    
    fileprivate func makeEmptySpinner() -> () -> [(AnySnapshotController, KripkeStatePropertyList)]? {
        var generated = false
        return {
            if true == generated {
                return nil
            }
            generated = true
            return []
        }
    }

    private func convert(from data: KripkeStatePropertyList) -> [String: Any] {
        var d: [String: Any] = [:]
        data.forEach {
            d[$0] = $1.value
        }
        return d
    }
    
    fileprivate func nextItem(
        inSpinners spinners: inout [() -> (AnySnapshotController, KripkeStatePropertyList)?],
        atIndex index: Int = 0,
        usingData data: [ExternalVariablesVerificationData]
    ) -> [(AnySnapshotController, KripkeStatePropertyList, Int)]? {
        if index >= spinners.count {
            return nil
        }
        // Just return the new item if we are able to successfully fetch it.
        if let (newItem, ps) = spinners[index]() {
            return [(newItem, ps, index)]
        }
        // Reset this spinner.
        spinners[index] = self.constructor.makeSpinner(
            fromExternalVariables: data[index].externalVariables,
            defaultValues: data[index].defaultValues,
            spinners: data[index].spinners
        )
        // Fetch the a value for the spinner before the current spinner.
        guard let newItems = self.nextItem(inSpinners: &spinners, atIndex: index + 1, usingData: data) else {
            return nil
        }
        // Use the starting default values as the value for this spinner.
        var new = data[index].externalVariables
        new.val = data[index].externalVariables.create(
            fromDictionary: self.convert(from: data[index].defaultValues)
        )
        return [(new, data[index].defaultValues, index)] + newItems
    }

}
