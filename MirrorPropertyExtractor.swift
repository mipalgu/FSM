/*
 * MirrorPropertyExtractor.swift
 * swiftfsm
 *
 * Created by Callum McColl on 20/11/2015.
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

public class MirrorPropertyExtractor: PropertiesExtractor, GlobalPropertyExtractor {

    /**
     *  Create a new `MirrorPropertyExtractor`.
     */
    public init() {}

    /**
     *  Extract all properties of a `GlobalVariables`.
     *
     *  - Parameter globals: The `GlobalVariables`.
     *
     *  - Returns: A dictionary where the key is the label of each variable in
     *  the `GlobalVariables` and the value is a `KripkeStateProperty`,
     *  representing the value of the variable.
     */
    public func extract<GV: GlobalVariables>(
        globals: GV
    ) -> [String: KripkeStateProperty] {
        return self.getPropertiesFromMirror(mirror: Mirror(reflecting: globals))
    }

    /**
     *  Extract all properties of `GlobalVariables`, Finite State Machine
     *  `Variables` and state properties.
     *
     *  - Parameter globals: The `GlobalVariables`.
     *
     *  - Parameter fsmVars: The `Variables` accessible for a Finite State
     *  Machine.
     *
     *  - Parameter state: The `StateType` that contains the state properties.
     *
     *  - Returns: A `KripkeStatePropertyList` that contains all the values for
     *  all the variables.
     */
    public func extract<GV: GlobalVariables>public func extract<G: GlobalVariables, F: Variables, S: StateType>(
        globals: G,
        fsmVars: F,
        state: S
    ) -> KripkeStatePropertyList where S: KripkeVariablesModifier {
        var stateProperties: [String: KripkeStateProperty] =
            self.getPropertiesFromMirror(
                mirror: Mirror(reflecting: state),
                manipulators: state.manipulators,
                validValues: state.validVars
            )
        // Ignore the validVars
        stateProperties["validVars"] = nil
        // Ignore the states name
        stateProperties["name"] = nil
        let fsmProperties: [String: KripkeStateProperty] =
            self.getPropertiesFromMirror(
                mirror: Mirror(reflecting: fsmVars)
            )
        let globalProperties: [String: KripkeStateProperty] = 
            self.getPropertiesFromMirror(
                mirror: Mirror(reflecting: globals)
            )
        return KripkeStatePropertyList(
            stateProperties: stateProperties,
            fsmProperties: fsmProperties,
            globalProperties: globalProperties
        )
    }

    /*
     *  Extract the properties from a mirror.
     *
     *  If the mirror has a superclassMirror then the superclasses properties
     *  are also extracted, giving the child values preference over the
     *  superclass values.
     */
    private func getPropertiesFromMirror(
        mirror: Mirror,
        manipulators: [String: (Any) -> Any] = [:],
        validValues: [String: [Any]] = [:]
    ) -> [String: KripkeStateProperty] {
        var p: [String: KripkeStateProperty] = [:]
        let parent: Mirror? = mirror.superclassMirror
        if (nil != parent) {
            p = self.getPropertiesFromMirror(
                mirror: parent!,
                validValues: validValues
            )
        }
        for child: Mirror.Child in mirror.children {
            guard let label = child.label else {
                continue
            }
            if let manipulator = manipulators[label] {
                p[label] = self.convertValue(
                    value: child.value,
                    validValues: [manipulator(child.value)]
                )
                continue
            }
            if (nil != validValues[label] && true == validValues[label]!.isEmpty) {
                continue
            }
            p[label] = self.convertValue(
                value: child.value,
                validValues: validValues[label]
            )
        }
        return p
    }
    
    /*
    *  Convert the value to a KripkeStateProperty.
    */
    private func convertValue(value: Any, validValues: [Any]?) -> KripkeStateProperty {
        let t = self.getKripkeStatePropertyType(
            value,
            validValues: validValues ?? [value]
        )
        return KripkeStateProperty(
            type: t.0,
            value: t.1
        )
    }
    
    /*
    *  Derive the KripkeStatePropertyType associated with a value.
    */
    private func getKripkeStatePropertyType(
        _ val: Any,
        validValues values: [Any]
    ) -> (KripkeStatePropertyTypes, Any) {
        switch (val) {
        case is Bool:
            let val: Bool = val as! Bool
            if (1 == values.count) {
                return (.Bool, values[0])
            }
            return (.Bool, values[val == false ? 0 : 1])
        case is Int:
            let values: [Int] = values as! [Int]
            let val: Int = val as! Int
            return (.Int, values[Int((val &+ values[0]) % values.count)])
        case is Int8:
            let values: [Int8] = values as! [Int8]
            let val: Int8 = val as! Int8
            let temp = values[Int((val &+ values[0]) % Int8(values.count))]
            return (.Int8, temp)
        case is Int16:
            let values: [Int16] = values as! [Int16]
            let val: Int16 = val as! Int16
            return (.Int16, values[Int((val &+ values[0]) % Int16(values.count))])
        case is Int32:
            let values: [Int32] = values as! [Int32]
            let val: Int32 = val as! Int32
            return (.Int32, values[Int((val &+ values[0]) % Int32(values.count))])
        case is Int64:
            let values: [Int64] = values as! [Int64]
            let val: Int64 = val as! Int64
            return  (.Int64, values[Int((val &+ values[0]) % Int64(values.count))])
        case is UInt:
            let values: [UInt] = values as! [UInt]
            let val: UInt = val as! UInt
            return  (.UInt, values[Int((val &+ values[0]) % UInt(values.count))])
        case is UInt8:
            let values: [UInt8] = values as! [UInt8]
            let val: UInt8 = val as! UInt8
            return  (.UInt8, values[Int((val &+ values[0]) % UInt8(values.count))])
        case is UInt16:
            let values: [UInt16] = values as! [UInt16]
            let val: UInt16 = val as! UInt16
            return  (.UInt16, values[Int((val &+ values[0]) % UInt16(values.count))])
        case is UInt32:
            let values: [UInt32] = values as! [UInt32]
            let val: UInt32 = val as! UInt32
            return  (.UInt32, values[Int((val &+ values[0]) % UInt32(values.count))])
        case is UInt64:
            let values: [UInt64] = values as! [UInt64]
            let val: UInt64 = val as! UInt64
            return  (.UInt64, values[Int((val &+ values[0]) % UInt64(values.count))])
        case is Float:
            let values: [Float] = values as! [Float]
            var val: Float = ((val as! Float) + values[0])
            val = val.truncatingRemainder(dividingBy: Float(values.count))
            return (
                .Float,
                values.lazy.map { abs(val - $0) }.lazy.sorted { $0 < $1 }.first!
            )
        case is Float80:
            let values: [Float80] = values as! [Float80]
            var val: Float80 = ((val as! Float80) + values[0])
            val = val.truncatingRemainder(dividingBy: Float80(values.count))
            return (
                .Float80,
                values.lazy.map { abs(val - $0) }.lazy.sorted { $0 < $1 }.first!
            )
        case is Double:
            let values: [Double] = values as! [Double]
            var val: Double = ((val as! Double) + values[0])
            val = val.truncatingRemainder(dividingBy: Double(values.count))
            return (
                .Float80,
                values.lazy.map { abs(val - $0) }.lazy.sorted { $0 < $1 }.first!
            )
        case is String:
            if (values.count == 1) {
                return (.String, values[0])
            }
            return (.String, val)
        case is KripkeCollection:
            let collection = (val as! KripkeCollection).toArray()
            var arr: [Any] = []
            collection.forEach {
                arr.append(self.getKripkeStatePropertyType($0, validValues: values).1)
            }
            return (.Collection(collection.map({ self.convertValue(value: $0, validValues: values) })), arr)
        default:
            return (.Some, val)
        }
    }
    
}
