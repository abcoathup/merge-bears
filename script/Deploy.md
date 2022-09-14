## Deploy

1. Deploy ExecutionLayerBear
forge script script/ExecutionLayerBear.s.sol:ExecutionLayerBearScript --rpc-url $OPTIMISM_RPC_URL --etherscan-api-key $OPTIMISTIC_ETHERSCAN_KEY --broadcast --verify -vvvv
2. Deploy ConsensusLayerBear
forge script script/ConsensusLayerBear.s.sol:ConsensusLayerBearScript --rpc-url $OPTIMISM_RPC_URL --etherscan-api-key $OPTIMISTIC_ETHERSCAN_KEY --broadcast --verify -vvvv
3. Deploy MergeBear(address(clToken), address(elToken));
MergeBear(0xfb3999711d4f309F6B71504268F79b3fD578DA6F, 0x22Cd0e2680f4B9aE140E3b9AbFA3463532e290Ff);
forge script script/MergeBear.s.sol:MergeBearScript --rpc-url $OPTIMISM_RPC_URL --etherscan-api-key $OPTIMISTIC_ETHERSCAN_KEY --broadcast --verify -vvvv
4. elToken.setMergeBear(0x63D29F9c28Ce781DacB284A99b1239A25E3e2159);
5. clToken.setMergeBear(0x63D29F9c28Ce781DacB284A99b1239A25E3e2159);
6. elToken.ownerMint
7. clToken.ownerMint
8. Setup EL Marketplace, set royalty 7.5% and address 0xc57c5aE582708e619Ec1BA7513480b2e7540935f
https://qx.app/collection/execution-layer-bears/settings?tab=1S
9. Setup CL Marketplace, set royalty 7.5% and address 0xc57c5aE582708e619Ec1BA7513480b2e7540935f
https://qx.app/collection/consensus-layer-bears/settings?tab=0
10. Setup MB Marketplace, set royalty 7.5% and address 0xc57c5aE582708e619Ec1BA7513480b2e7540935f
https://qx.app/collection/merge-bears/settings
11. change owner EL
12. change owner CL
13. change owner MB


3675 Execution Layer Bears to celebrate the Merge (EIP3675).  All royalties go to Ethereum Core Developers via the Protocol Guild.  Holders of both an Execution Layer Bear + a Consensus Layer Bear can mint a Merge bear.  ERC4883 composable NFT.  

3675 Consensus Layer Bears to celebrate the Merge (EIP3675).  All royalties go to Ethereum Core Developers via the Protocol Guild.  Holders of both an Execution Layer Bear + a Consensus Layer Bear can mint a Merge bear.  ERC4883 composable NFT.  

3675 Merge Bears to celebrate the Merge (EIP3675).  All royalties go to Ethereum Core Developers via the Protocol Guild.  Holders of both an Execution Layer Bear + a Consensus Layer Bear can mint a Merge bear.  ERC4883 composable NFT.  