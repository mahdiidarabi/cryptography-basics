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
    uint256 constant r    = 21888242871839275222246405745257275088548364400416034343698204186575808495617;
    // Base field size
    uint256 constant q   = 21888242871839275222246405745257275088696311157297823662689037894645226208583;

    // Verification Key data
    uint256 constant alphax  = 18248299117841700015746817961553577036322962925198437142950534447302048944761;
    uint256 constant alphay  = 5071559314321723049436793489785575471189447029730754490233017009328179144595;
    uint256 constant betax1  = 3444840327675111398044597191886467709791160517584584504052040864777938583629;
    uint256 constant betax2  = 7158978118187994336682647120958387465055873646138542961715322003264400458346;
    uint256 constant betay1  = 13987661549675270147536566761532950967554318604809221246278638055957178753910;
    uint256 constant betay2  = 8685844266727380614248122577566398321738798332923902408398475338389835816245;
    uint256 constant gammax1 = 11559732032986387107991004021392285783925812861821192530917403151452391805634;
    uint256 constant gammax2 = 10857046999023057135944570762232829481370756359578518086990519993285655852781;
    uint256 constant gammay1 = 4082367875863433681332203403145435568316851327593401208105741076214120093531;
    uint256 constant gammay2 = 8495653923123431417604973247489272438418190587263600148770280649306958101930;
    uint256 constant deltax1 = 21026241517490901945838342983934706631613952580685951232481926668926133527229;
    uint256 constant deltax2 = 10800471511402887489968392905330294290181176059395146709069768145551116691029;
    uint256 constant deltay1 = 5944681593358133967883232634943648778992204111082832729170209312302563980094;
    uint256 constant deltay2 = 20180319855659536024583211563050664300352423179465627678735057515393144094169;

    
    uint256 constant IC0x = 14855322418346296744675995183801969269221905186669524585593998890962476588920;
    uint256 constant IC0y = 3940854395967250471438289940838699236742512602426371041611255851123150501599;
    
    uint256 constant IC1x = 19835499392717480475856423320986774409791233800783319229401650933888767061853;
    uint256 constant IC1y = 11318090803523210625358254915944134409038057402628482363930705966005466699695;
    
    uint256 constant IC2x = 8952015185618665057244524268676782188781792428346397410710072395630814356205;
    uint256 constant IC2y = 15023060805525865466138074856035175231860368761864286516302484368673105285689;
    
    uint256 constant IC3x = 6677498782630375897059639317837249320386083235527665199470723001205174064197;
    uint256 constant IC3y = 8591669588994432594583788571812011194454992071661534220507048525917970407121;
    
    uint256 constant IC4x = 17111172317530735250485993647765944586885802807558464021472186573376958397263;
    uint256 constant IC4y = 19001367125289073672314562170444250168092560895715852432448590225889501723504;
    
    uint256 constant IC5x = 14996025702590117865145892715012927465443390812843257722840930913165519198117;
    uint256 constant IC5y = 6762018988744147038425275639642341857501544527895872845364006032889226121974;
    
    uint256 constant IC6x = 436232376569755660859765420211562772735366363917580205951595827610918776918;
    uint256 constant IC6y = 4723969451225548482759413020583614044896339096629563803771120726112954838621;
    
    uint256 constant IC7x = 17036500167026555134151316841130136461588391398113282076409770731468192488720;
    uint256 constant IC7y = 1273053358129448283295973571241486964458487414597274306269831727415629927431;
    
    uint256 constant IC8x = 15531371594701450822486651590942408422829549345346154465829050639043298132479;
    uint256 constant IC8y = 4576311717862066624720639708013951763047979491293154871479229521590884536832;
    
    uint256 constant IC9x = 9271402339594392512988416904790906910739829422809463888929896152650233317943;
    uint256 constant IC9y = 20649407652884886734838562166613904862614580083830296688883081484248424717541;
    
    uint256 constant IC10x = 8496439764649198253323858468672658511928179485544155510274692648377074511145;
    uint256 constant IC10y = 17401371705484990447375729616179459364341944947679202609062977404186955959237;
    
    uint256 constant IC11x = 21810200546911064234945267480909761005397410074259196653573831582831700402399;
    uint256 constant IC11y = 15311049717831374888628372864185589350314342031196702902548838845883478749613;
    
    uint256 constant IC12x = 8094638760907859728588173289890415781030177338754256950672721417964747763903;
    uint256 constant IC12y = 536084124887908474933984775022714395859219542971697457661947678031502626915;
    
    uint256 constant IC13x = 19362784589707801377920408021705973726134952618581227413968868510726926045118;
    uint256 constant IC13y = 18808154934689065221482946052508097682032429344351090326163458314581177479609;
    
    uint256 constant IC14x = 8275266992209738885928617151729236575567251889547647223707223177666745396859;
    uint256 constant IC14y = 8073903800981066825680298419067565920786530479275061569262050494971863886968;
    
 
    // Memory data
    uint16 constant pVk = 0;
    uint16 constant pPairing = 128;

    uint16 constant pLastMem = 896;

    function verifyProof(uint[2] calldata _pA, uint[2][2] calldata _pB, uint[2] calldata _pC, uint[14] calldata _pubSignals) public view returns (bool) {
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
                
                g1_mulAccC(_pVk, IC1x, IC1y, calldataload(add(pubSignals, 0)))
                
                g1_mulAccC(_pVk, IC2x, IC2y, calldataload(add(pubSignals, 32)))
                
                g1_mulAccC(_pVk, IC3x, IC3y, calldataload(add(pubSignals, 64)))
                
                g1_mulAccC(_pVk, IC4x, IC4y, calldataload(add(pubSignals, 96)))
                
                g1_mulAccC(_pVk, IC5x, IC5y, calldataload(add(pubSignals, 128)))
                
                g1_mulAccC(_pVk, IC6x, IC6y, calldataload(add(pubSignals, 160)))
                
                g1_mulAccC(_pVk, IC7x, IC7y, calldataload(add(pubSignals, 192)))
                
                g1_mulAccC(_pVk, IC8x, IC8y, calldataload(add(pubSignals, 224)))
                
                g1_mulAccC(_pVk, IC9x, IC9y, calldataload(add(pubSignals, 256)))
                
                g1_mulAccC(_pVk, IC10x, IC10y, calldataload(add(pubSignals, 288)))
                
                g1_mulAccC(_pVk, IC11x, IC11y, calldataload(add(pubSignals, 320)))
                
                g1_mulAccC(_pVk, IC12x, IC12y, calldataload(add(pubSignals, 352)))
                
                g1_mulAccC(_pVk, IC13x, IC13y, calldataload(add(pubSignals, 384)))
                
                g1_mulAccC(_pVk, IC14x, IC14y, calldataload(add(pubSignals, 416)))
                

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
            
            checkField(calldataload(add(_pubSignals, 0)))
            
            checkField(calldataload(add(_pubSignals, 32)))
            
            checkField(calldataload(add(_pubSignals, 64)))
            
            checkField(calldataload(add(_pubSignals, 96)))
            
            checkField(calldataload(add(_pubSignals, 128)))
            
            checkField(calldataload(add(_pubSignals, 160)))
            
            checkField(calldataload(add(_pubSignals, 192)))
            
            checkField(calldataload(add(_pubSignals, 224)))
            
            checkField(calldataload(add(_pubSignals, 256)))
            
            checkField(calldataload(add(_pubSignals, 288)))
            
            checkField(calldataload(add(_pubSignals, 320)))
            
            checkField(calldataload(add(_pubSignals, 352)))
            
            checkField(calldataload(add(_pubSignals, 384)))
            
            checkField(calldataload(add(_pubSignals, 416)))
            

            // Validate all evaluations
            let isValid := checkPairing(_pA, _pB, _pC, _pubSignals, pMem)

            mstore(0, isValid)
             return(0, 0x20)
         }
     }
 }
