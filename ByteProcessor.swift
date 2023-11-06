//
//  ByteProcessor.swift
//  Dream ATM
//
//  Created by Akshansh Thakur on 15/09/22.
//

import Foundation

class ByteProcessor: NSObject {
    
    /// Two bytes inside of a data packet are allocated to communicate the number of packets
    let numberOfPacketsByteSize = 2
    
    /// Two bytes are allocated in the data to communicate the length of each packet
    let lengthOfPacketsByteSize = 2
    
    /// 4 Bytes represent each node inside a packet
    let packetSubDataLength = 4
    
    
    /*
     
        |--|           |- -|       |--||--||--|      |- -|       |--||--||--|
         NP             LP1                           LP2
     (No of packets)  (P1 Length)     (Packet 1)   (P2 Length)     (Packet 2) ....
     
     */
    
    let data: Data
    
    init(data: Data) {
        self.data = data
    }
    
    
    func processByteData() -> [[UInt32]] {
        
        var index = 1
        
        // Get first two bytes.. This has the number of packets
        // Index [0, 1]
        let numberOfPacketsData = data[0...index]
        
        let numberOfPackets = Int(getInt16Value(data: numberOfPacketsData))
        
        var dataPackets = [[UInt32]]()
        
        // Loop Through Each Packet
        Array(0...(numberOfPackets - 1)).forEach { value in
            index += 2
            
            let packetLengthData = data[(index - 1)...index]
            
            guard let scalarPacketLength = String(data: packetLengthData, encoding: .utf16)?.unicodeScalars else {
                return
            }
            guard scalarPacketLength.count == 1, let packetLength = scalarPacketLength.first?.value else {
                return
            }
            
            var packet = [UInt32]()
            
            for value in stride(
                from: 0,
                to: packetLength - 1,
                by: packetSubDataLength
            ) {
                packet.append(
                    getInt32Value(
                        data: data[
                            (
                                value + UInt32(
                                    index + 1
                                )
                            )...(
                                value + UInt32(
                                    index + 4
                                )
                            )
                        ]
                    )
                )
            }
            
            dataPackets.append(packet)
            
            index += Int(packetLength)
            
        }
        
        return dataPackets
    }
    
    func getInt32Value(data: Data) -> UInt32 {
        return UInt32(bigEndian: data.withUnsafeBytes { $0.pointee })
    }
    
    func getInt16Value(data: Data) -> UInt16 {
        return UInt16(bigEndian: data.withUnsafeBytes { $0.pointee })
    }
}
