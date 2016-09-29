/*
 * HashTableKripkeRingletKripkeStructureGenerator.swift 
 * FSM 
 *
 * Created by Callum McColl on 24/09/2016.
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

public class HashTableKripkeRingletKripkeStructureGenerator<
    E: PropertiesExtractor,
    SpinnersFactory: GlobalsSpinnerConstructorFactoryType
>: KripkeRingletKripkeStructureGenerator {

    private let extractor: E

    private let factory: SpinnersFactory

    public init(extractor: E, factory: SpinnersFactory) {
        self.extractor = extractor
        self.factory = factory
    }

    public func generate<R: KripkeRinglet>(
        machine: String,
        fsm: String,
        initialState: R._StateType,
        ringlet: R
    ) -> KripkeStructure where
        R._StateType._TransitionType == Transition<R._StateType>
    {
        let fsmVars = ringlet.fsmVars
        let globals = ringlet.globals
        let constructor = self.factory.make(globals: globals.val)
        var jobs: [(R._StateType, R, R.FSMVariables.Vars, [String: R._StateType], [KripkeState])] = 
            [(
                initialState.clone(transitions: initialState.transitions),
                ringlet.clone(),
                fsmVars.vars.clone(),
                [:],
                []
            )]
        var hashTable: [String: Bool] = [:]
        var states: [KripkeState] = []
        while (false == jobs.isEmpty) { 
            let job = jobs.removeFirst()
            let state = job.0.clone(transitions: job.0.transitions)
            let ringlet = job.1.clone()
            let vars = job.2.clone()
            var clones = job.3
            var history = job.4
            let spinner: () -> R.Container.Class? = constructor()
            // Spin the globals and generate states for each one.
            while let gs = spinner() {
                let p: KripkeStatePropertyList = self.extractor.extract(
                        globals: gs,
                        fsmVars: vars,
                        state: state
                    )
                print(p)
                // Have we seen this combination of variables before?
                guard nil == hashTable[p.description] else {
                    continue
                }
                hashTable[p.description] = true
                let stateClone = state.clone(transitions: state.transitions)
                clones[stateClone.name] = stateClone
                let ringletClone = ringlet.clone()
                globals.val = gs
                fsmVars.vars = vars.clone()
                let nextState = ringletClone.execute(state: stateClone)
                // Generate Kripke States
                let kripkeStates: [KripkeState] = self.makeKripkeStates(
                    machine: machine,
                    fsm: fsm,
                    state: stateClone.name,
                    snapshots: ringletClone.snapshots,
                    previousState: history.last
                )
                states.append(contentsOf: kripkeStates)
                history.append(contentsOf: kripkeStates)
                let nextStateClone = nextState.clone(
                        transitions: nextState.transitions.map { 
                            guard let clone = clones[$0.target.name] else {
                                return $0
                            }
                            return $0.map { _ in clone }
                        }
                    )
                print("nextState: \(nextStateClone)")
                // Add the next state to the job queue
                jobs.append((
                    nextStateClone,
                    ringletClone,
                    fsmVars.vars,
                    clones,
                    history
                ))
            }
        }
        print(states.count)
        return KripkeStructure(states: states) 
    }

    private func makeKripkeStates(
        machine: String,
        fsm: String,
        state: String,
        snapshots: [KripkeStatePropertyList],
        previousState: KripkeState?
    ) -> [KripkeState] {
        if (snapshots.count < 2) {
            print("no snapshots")
            return []
        }
        var snapshots = snapshots
        var lastProperties: KripkeStatePropertyList = snapshots.removeFirst()
        var lastState: KripkeState? = previousState
        // Create the Kripke States
        return snapshots.map {
            let state: KripkeState = KripkeState(
                state: state,
                fsm: fsm,
                machine: machine,
                beforeProperties: lastProperties,
                afterProperties: $0,
                previous: lastState
            )
            lastProperties = $0
            lastState = state
            return state
        }

    }

}
