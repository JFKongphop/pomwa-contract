// SPDX-License-Identifier: GPL-3.0
/*
  Copyright 2021 0KIMS association.

  This file is generated with [snarkJS](https://github.com/iden3/snarkjs).

  snarkJS is a free software: you can redistribute it and/or modify it
  under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  snarkJS is distributed in the hope that it will be useful, but WITHOUT
  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
  or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public
  License for more details.

  You should have received a copy of the GNU General Public License
  along with snarkJS. If not, see <https://www.gnu.org/licenses/>.
*/

pragma solidity >=0.7.0 <0.9.0;

contract Groth16Verifier {
  // Scalar field size
  uint256 constant r = 21888242871839275222246405745257275088548364400416034343698204186575808495617;
  // Base field size
  uint256 constant q = 21888242871839275222246405745257275088696311157297823662689037894645226208583;

  // Verification Key data
  uint256 constant alphax  = 9433546317119489459175699715818081835170694128607044089640495322181360647816;
  uint256 constant alphay  = 17402023096120810699469787503267802886851484566559883016793779244146753241389;
  uint256 constant betax1  = 16893353922780322223559374392231321594119649450942635916385498215231516466296;
  uint256 constant betax2  = 19926955101667928783499834929048302952705159165158029702747057704861271751755;
  uint256 constant betay1  = 10991570690407263528282550207839124229631202464204424731567853432270995567119;
  uint256 constant betay2  = 13872509086389914554786124385082492036838791214772457519217508196865026681650;
  uint256 constant gammax1 = 11559732032986387107991004021392285783925812861821192530917403151452391805634;
  uint256 constant gammax2 = 10857046999023057135944570762232829481370756359578518086990519993285655852781;
  uint256 constant gammay1 = 4082367875863433681332203403145435568316851327593401208105741076214120093531;
  uint256 constant gammay2 = 8495653923123431417604973247489272438418190587263600148770280649306958101930;
  uint256 constant deltax1 = 11559732032986387107991004021392285783925812861821192530917403151452391805634;
  uint256 constant deltax2 = 10857046999023057135944570762232829481370756359578518086990519993285655852781;
  uint256 constant deltay1 = 4082367875863433681332203403145435568316851327593401208105741076214120093531;
  uint256 constant deltay2 = 8495653923123431417604973247489272438418190587263600148770280649306958101930;
  uint256 constant IC0x = 12720384354425441231171889409530100349668437439579860535873339432008553107968;
  uint256 constant IC0y = 5495790107113699834545829144532372432397480445343062009666478761092002006103;
  
  // Memory data
  uint16 constant pVk = 0;
  uint16 constant pPairing = 128;

  uint16 constant pLastMem = 896;

  function verifyProof(
    uint[2] calldata _pA, 
    uint[2][2] calldata _pB, 
    uint[2] calldata _pC
  ) public view returns (bool) {
    uint[] calldata _pubSignals;

    assembly {
      function checkField(v) {
        if iszero(lt(v, r)) {
          mstore(0, 0)
          return(0, 0x20)
        }
      }
      
      // G1 function to multiply a G1 value(x,y) to value in an address
      function g1_mulAccC(pR, x, y, s) {
        let success
        let mIn := mload(0x40)
        mstore(mIn, x)
        mstore(add(mIn, 32), y)
        mstore(add(mIn, 64), s)

        success := staticcall(sub(gas(), 2000), 7, mIn, 96, mIn, 64)

        if iszero(success) {
          mstore(0, 0)
          return(0, 0x20)
        }

        mstore(add(mIn, 64), mload(pR))
        mstore(add(mIn, 96), mload(add(pR, 32)))

        success := staticcall(sub(gas(), 2000), 6, mIn, 128, pR, 64)

        if iszero(success) {
          mstore(0, 0)
          return(0, 0x20)
        }
      }

      function checkPairing(pA, pB, pC, pubSignals, pMem) -> isOk {
        let _pPairing := add(pMem, pPairing)
        let _pVk := add(pMem, pVk)

        mstore(_pVk, IC0x)
        mstore(add(_pVk, 32), IC0y)

        // Compute the linear combination vk_x
        

        // -A
        mstore(_pPairing, calldataload(pA))
        mstore(add(_pPairing, 32), mod(sub(q, calldataload(add(pA, 32))), q))

        // B
        mstore(add(_pPairing, 64), calldataload(pB))
        mstore(add(_pPairing, 96), calldataload(add(pB, 32)))
        mstore(add(_pPairing, 128), calldataload(add(pB, 64)))
        mstore(add(_pPairing, 160), calldataload(add(pB, 96)))

        // alpha1
        mstore(add(_pPairing, 192), alphax)
        mstore(add(_pPairing, 224), alphay)

        // beta2
        mstore(add(_pPairing, 256), betax1)
        mstore(add(_pPairing, 288), betax2)
        mstore(add(_pPairing, 320), betay1)
        mstore(add(_pPairing, 352), betay2)

        // vk_x
        mstore(add(_pPairing, 384), mload(add(pMem, pVk)))
        mstore(add(_pPairing, 416), mload(add(pMem, add(pVk, 32))))


        // gamma2
        mstore(add(_pPairing, 448), gammax1)
        mstore(add(_pPairing, 480), gammax2)
        mstore(add(_pPairing, 512), gammay1)
        mstore(add(_pPairing, 544), gammay2)

        // C
        mstore(add(_pPairing, 576), calldataload(pC))
        mstore(add(_pPairing, 608), calldataload(add(pC, 32)))

        // delta2
        mstore(add(_pPairing, 640), deltax1)
        mstore(add(_pPairing, 672), deltax2)
        mstore(add(_pPairing, 704), deltay1)
        mstore(add(_pPairing, 736), deltay2)


        let success := staticcall(sub(gas(), 2000), 8, _pPairing, 768, _pPairing, 0x20)

        isOk := and(success, mload(_pPairing))
      }

      let pMem := mload(0x40)
      mstore(0x40, add(pMem, pLastMem))

      // Validate that all evaluations ∈ F
      
      checkField(calldataload(add(_pubSignals.offset, 0)))
      

      // Validate all evaluations
      let isValid := checkPairing(_pA, _pB, _pC, _pubSignals.offset, pMem)

      mstore(0, isValid)
      return(0, 0x20)
    }
  }
}
