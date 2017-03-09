/*
 * KripkeRingletKripkeStructureGenerator.swift 
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

import KripkeStructure

/**
 *  Provides a way to generate a `KripkeStructure` from a `KripkeRinglet`.
 */
public class KripkeRingletKripkeStructureGenerator<
    CD: CycleDetector,
    E: PropertiesExtractor,
    SpinnersFactory: ExternalsSpinnerConstructorFactoryType
>: KripkeRingletKripkeStructureGeneratorType where CD.Element == World {

    private let cycleDetector: CD

    private let extractor: E

    private let factory: SpinnersFactory

    private typealias Data<R: KripkeRinglet> = (
            state: R._StateType,
            ringlet: R,
            fsmVars: R.FSMVariables.Vars,
            last: KripkeState?,
            allStateProperties: [String: [String: KripkeStateProperty]],
            data: CD.Data
        )

    /**
     *  Create a new `KripkeRingletKripkeStructureGenerator`.
     *
     *  - Parameter cycleDetector: Used to detect cycles in the structure.
     *
     *  - Parameter extractor: Used to extract the value of all the different
     *  variables.
     *
     *  - Parameter factory: Used to create the `Spinners.Spinner`s that are
     *  used to evaluate all possible variations of the `GlobalVariables`.
     */
    public init(cycleDetector: CD, extractor: E, factory: SpinnersFactory) {
        self.cycleDetector = cycleDetector
        self.extractor = extractor
        self.factory = factory
    }

    /**
     *  Generate a new `KripkeStructure`.
     *
     *  - Parameter machine: The name of the machine.
     *
     *  - Parameter fsm: The name of the Finite State Machine.
     *
     *  - Parameter intialState: The starting state of the Finite State Machine.
     *
     *  - Parameter ringlet: The `KripkeRinglet` which is used to execute and
     *  take snapshots of the states.
     *
     *  - Returns: A `KripkeStructure` which represents all the possible ways
     *  in which the Finite State Machine can be executed.
     */
    public func generate<R: KripkeRinglet>(
        machine: String,
        fsm: String,
        initialState: R._StateType,
        ringlet: R
    ) -> KripkeStructure where
        R._StateType: KripkeVariablesModifier,
        R._StateType._TransitionType == Transition<R._StateType, R._StateType>
    {
        let fsmVars = ringlet.fsmVars
        var externalVariables = ringlet.externalVariables
        let constructors = externalVariables.map { self.factory.make(externalVariables: $0) }
        var originals: [String: R._StateType] = [initialState.name: initialState]
        var defaults: [String: [String: KripkeStateProperty]] = [
            initialState.name: self.extractor.extract(
                externalVariables: externalVariables,
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
                self.cycleDetector.initialData
            )]
        var states: [[KripkeState]] = []
        while (false == jobs.isEmpty) { 
            let job = jobs.removeFirst()
            let state = job.state.clone()
            let ringlet = job.ringlet.clone()
            let vars = job.fsmVars.clone()
            var allStateProperties = job.allStateProperties
            let properties = self.extractor.extract(
                    externalVariables: externalVariables,
                    fsmVars: vars,
                    state: state
                ).stateProperties
            originals[state.name]!.update(
                    fromDictionary: self.reduce(properties)
                )
            state.update(fromDictionary: self.reduce(properties))
            allStateProperties[state.name] = properties
            let spinners: [() -> AnySnapshotController?] = constructors.map { $0() }
            let spinner = self.makeSpinner(fromSpinners: spinners)
            print(jobs.count)
            // Spin the globals and generate states for each one.
            while let es = spinner() {
                let data = job.data
                let ps = self.extractor.extract(
                    externalVariables: es,
                    fsmVars: vars,
                    state: state
                )
                let world = World(
                    executingState: state.name,
                    externalVariables: ps.externalProperties,
                    fsmVars: ps.fsmProperties,
                    stateProperties: defaults
                        <| allStateProperties
                        <| [state.name: ps.stateProperties]
                )
                let (inCycle, newData) = self.cycleDetector.inCycle(
                    data: data,
                    element: world
                )
                // Have we seen this combination of variables before?
                if (true == inCycle) {
                    continue
                }
                let stateClone = state.clone()
                let ringletClone = ringlet.clone()
                externalVariables = es
                fsmVars.vars = vars.clone()
                let nextState = ringletClone.execute(state: originals[stateClone.name]!)
                if (nil == originals[nextState.name]) {
                    originals[nextState.name] = nextState
                    defaults[nextState.name] = self.extractor.extract(
                            externalVariables: es,
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
                guard let _ = kripkeStates.first else {
                    continue
                }
                states.append(kripkeStates)
                var nextStateClone = nextState.clone()
                nextStateClone.transitions = nextStateClone.transitions.map {
                    $0.map { $0.clone() }
                }
                // Add the next state to the job queue
                jobs.insert((
                    nextStateClone,
                    ringletClone,
                    fsmVars.vars,
                    kripkeStates.last,
                    allStateProperties,
                    newData
                ), at: 0)
            }
        }
        print(states.count)
        return KripkeStructure(states: states) 
    }

    private func makeSpinner(fromSpinners spinners: [() -> AnySnapshotController?]) -> () -> [AnySnapshotController]? {
        var spinners = spinners
        var defaultSpinners = spinners
        var i = spinners.count
        var latest = spinners.map { $0()! }
        let defaults = latest
        let spin: () -> AnySnapshotController? = {
            if (i < 0) {
                return nil
            }
            return spinners[i]()
        }
        return {
            guard let val = spin() else {
                var nextVal: AnySnapshotController?
                repeat  {
                    spinners[i] = defaultSpinners[i]
                    latest[i] = defaults[i]
                    i -= 1
                    nextVal = spin()
                } while nil == nextVal && i >= 0
                guard let temp = nextVal else {
                    return nil
                }
                latest[i] = temp
                i = spinners.count
                return latest
            }
            latest[i] = val
            i = spinners.count
            return latest
        }
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
        if (true == snapshots.isEmpty) {
            fatalError("Ringlet did not take any snapshots!")
        }
        var snapshots = snapshots
        // Create the Kripke States
        let firstState: KripkeState = KripkeState(
            state: state,
            fsm: fsm,
            machine: machine,
            properties: snapshots.removeFirst(),
            previous: previousState
        )
        previousState?.targets.append(firstState)
        return snapshots.reduce([firstState]) { (states: [KripkeState], snapshot: KripkeStatePropertyList) in
            let temp = KripkeState(
                state: state,
                fsm: fsm,
                machine: machine,
                properties: snapshots.removeFirst(),
                previous: states.last!
            )
            // Ignore repeating states.
            if (temp == states.last!) {
                return states
            }
            states.last!.targets.append(temp)
            var states: [KripkeState] = states
            states.append(temp)
            return states
        }
    }
    
}
