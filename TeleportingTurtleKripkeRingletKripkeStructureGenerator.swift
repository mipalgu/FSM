/*
 * TeleportingTurtleKripkeRingletKripkeStructureGenerator.swift 
 * FSM 
 *
 * Created by Callum McColl on 12/10/2016.
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

public class TeleportingTurtleKripkeRingletKripkeStructureGenerator<
    E: PropertiesExtractor,
    SpinnersFactory: GlobalsSpinnerConstructorFactoryType
>: KripkeRingletKripkeStructureGenerator {

    private let extractor: E

    private let factory: SpinnersFactory

    private typealias Data<R: KripkeRinglet> = (
            state: R._StateType,
            ringlet: R,
            fsmVars: R.FSMVariables.Vars,
            last: KripkeState?,
            allStateProperties: [String: [String: KripkeStateProperty]],
            turtle: World?,
            power: Int,
            length: Int
        )

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
        R._StateType: KripkeVariablesModifier,
        R._StateType._TransitionType == Transition<R._StateType>
    {
        let fsmVars = ringlet.fsmVars
        let globals = ringlet.globals
        let constructor = self.factory.make(globals: globals.val)
        var originals: [String: R._StateType] = [initialState.name: initialState]
        var defaults: [String: [String: KripkeStateProperty]] = [
            initialState.name: self.extractor.extract(
                globals: globals.val,
                fsmVars: fsmVars.vars,
                state: initialState
            ).stateProperties
        ]
        var jobs: [Data<R>] = [(
                initialState.clone(),
                ringlet.clone(),
                fsmVars.vars.clone(),
                nil,
                [:],
                nil,
                1,
                1
            )]
        var states: [KripkeState] = []
        while (false == jobs.isEmpty) { 
            let job = jobs.removeFirst()
            let state = job.state.clone()
            let ringlet = job.ringlet.clone()
            let vars = job.fsmVars.clone()
            var allStateProperties = job.allStateProperties
            let properties = self.extractor.extract(
                    globals: globals.val,
                    fsmVars: vars,
                    state: state
                ).stateProperties
            originals[state.name]!.update(
                    fromDictionary: self.reduce(properties)
                )
            allStateProperties[state.name] = properties
            let spinner: () -> R.Container.Class? = constructor()
            // Spin the globals and generate states for each one.
            while let gs = spinner() {
                let stateClone = state.clone()
                let ringletClone = ringlet.clone()
                globals.val = gs
                fsmVars.vars = vars.clone()
                let nextState = ringletClone.execute(state: originals[stateClone.name]!)
                if (nil == originals[nextState.name]) {
                    originals[nextState.name] = nextState
                    defaults[nextState.name] = self.extractor.extract(
                            globals: gs,
                            fsmVars: fsmVars.vars,
                            state: nextState
                        ).stateProperties
                }
                // Generate Kripke States
                let kripkeStates: [KripkeState] = self.makeKripkeStates(
                    machine: machine,
                    fsm: fsm,
                    state: stateClone.name,
                    snapshots: ringletClone.snapshots,
                    previousState: job.last
                )
                guard let first = kripkeStates.first else {
                    continue
                }
                let world = World(
                    executingState: stateClone.name,
                    globals: first.beforeProperties.globalProperties,
                    fsmVars: first.beforeProperties.fsmProperties,
                    stateProperties: defaults
                        <| allStateProperties
                        <| [stateClone.name: first.beforeProperties.stateProperties]
                )
                // Have we found the turtle?
                if (job.turtle != nil && job.turtle! == world) {
                    continue
                }
                states.append(contentsOf: kripkeStates)
                var nextStateClone = nextState.clone()
                nextStateClone.transitions = nextStateClone.transitions.map {
                    $0.map { $0.clone() }
                }
                let length: Int
                let power: Int
                let turtle: World
                if (job.length >= job.power) {
                    length = 1
                    power = job.power * 2
                    turtle = world
                } else {
                    length = job.length + 1
                    power = job.power
                    turtle = job.turtle!
                }
                // Add the next state to the job queue
                jobs.append((
                    nextStateClone,
                    ringletClone,
                    fsmVars.vars,
                    kripkeStates.last,
                    allStateProperties,
                    turtle,
                    power,
                    length
                ))
            }
        }
        print(states.count)
        return KripkeStructure(states: states) 
    }

    private func reduce(_ p: [String: KripkeStateProperty]) -> [String: Any] {
        return p.reduce([:]) {
            var d = $0
            d[$1.0] = $1.1.value
            return d
        }
    }

    private func makeKripkeStates(
        machine: String,
        fsm: String,
        state: String,
        snapshots: [KripkeStatePropertyList],
        previousState: KripkeState?
    ) -> [KripkeState] {
        if (snapshots.count < 2) {
            fatalError("Ringlet did not generate enough snapshots")
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

fileprivate struct World: CustomStringConvertible {

    public var description: String {
        return "\(executingState), \(self.globals), \(self.fsmVars), \(self.stateProperties)"
    }

    let executingState: String

    let globals: [String: KripkeStateProperty]

    let fsmVars: [String: KripkeStateProperty]

    let stateProperties: [String: [String: KripkeStateProperty]]

}

fileprivate func ==(lhs: World, rhs: World) -> Bool {
    return lhs.description == rhs.description
}
