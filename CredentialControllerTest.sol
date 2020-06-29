
pragma solidity ^0.4.4;

import "./CredentialController.sol";


contract CredentialControllerTest{
    
    CredentialController private credentialController;

    function CredentialControllerTest
    (
        address credentialControllerAddress
    )
    public
    {
        credentialController=CredentialController(credentialControllerAddress);
    }

/*
函数用途：测试设置某类型cpt的可发行的限量数额功能
参数：
    cptid：要使用的 cpt 的编号
    limitNum：该类型 cpt 限量发行的额数
返回值：无
*/    
    function setLimitTest
    (
       uint cptid,
       uint limitNum    
    )
    public
    {
        credentialController.setLimit(cptid,limitNum);
    }

/*
函数用途：测试生成credentialID号与随机数共
参数：
    cptid：要获取的 cpt 的编号
返回值：无
*/   
    function generateIdAndRandNumTest
    (
     uint cptid
    )
    public
    {
        credentialController.generateIdAndRandNum(cptid);
    }
    
/*
函数用途：测试获取某crendential生成的随机数功能
参数：
    creid：要使用的credential的ID号
返回值：无
*/     
    function getRandNumOfCreidTest
    (
     uint creid
    )
    public
    {
        credentialController.getRandNumOfCreid(creid);
    }
    
/*
函数用途：测试获取某类型cpt的可发行的限量数额与已发行credential数量功能
参数：
    cptid：要获取的 cpt 的编号
返回值：无
*/ 
    function getCptILimitAndIssuedNumTest
    (
        uint cptid
    )
    public
    {
        credentialController.getCptILimitAndIssuedNum(cptid);
    }

}