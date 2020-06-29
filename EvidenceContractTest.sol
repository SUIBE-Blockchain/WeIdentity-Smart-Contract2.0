pragma solidity ^0.4.4;


import "./EvidenceContract.sol";

contract EvidenceContractTest{
   
    EvidenceContract private evidenceContract;
    
    function EvidenceContractTest
    (
        address evidenceContractAddress
    )
    public
    {
        evidenceContract=EvidenceContract(evidenceContractAddress);
    }
    
/*
函数用途：测试存证上链功能
参数：
  hash：查询存证的key
  sig：发布存证的人的签名
  extra：任意额外数据
  updated：当前event的更新时间
  creid：某类型的cpt编号
  randNum：随机数
返回值：无
*/ 
    function createEvidenceTest(
        string hash,
        string sig,
        string extra,
        uint256 updated,
        uint creid,
        uint randNum
       
    )
    public
    {
        evidenceContract.createEvidence(hash,sig,extra,updated,creid,randNum);
    }
    
    
}