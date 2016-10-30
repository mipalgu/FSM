/*
 * GlobalsSpinnerConstructor.swift 
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

/**
 *  Provides a way to create a `GlobalVariables` `Spinners.Spinner`.
 */
public class GlobalsSpinnerConstructor<
    SR: SpinnerRunnerType
>: GlobalsSpinnerConstructorType {

    private let runner: SR

    /**
     *  Create a new `GlobalsSpinnerConstructor`.
     *
     *  - Parameter runner: Will be used when executing the `Spinners.Spinner`. 
     */
    public init(runner: SR) {
        self.runner = runner
    }

    /**
     *  Create a `Spinners.Spinner` for an instance of `GlobalVariables`.
     *
     *  - Parameter defaultValues: The starting values of each spinner.
     *
     *  - Parameter spinners: A dictionary where the key represents a variables
     *  label and the value is a `Spinners.Spinner` for that variable.
     *
     *  - Returns a `Spinners.Spinner` that return the `GlobalVariables`.
     */
    public func makeSpinner<GV: GlobalVariables>(
        defaultValues: [String: Any],
        spinners: [String: (Any) -> Any?]
    ) -> () -> GV? {
        var latest: [String: Any]? = defaultValues
        return { () -> GV? in
            guard let temp = latest else {
                return nil
            }
            guard let vs = self.runner.spin(
                      index: temp.startIndex,
                      vars: temp,
                      defaultValues: defaultValues,
                      spinners: spinners
                  )
            else {
                latest = nil
                return GV(fromDictionary: temp)
            }
            latest = vs
            return GV(fromDictionary: temp)
        }
    }

}
