pragma solidity ^0.4.4;


import "./AuthorityIssuerController.sol";


contract AuthorityIssuerControllerTest{
    
AuthorityIssuerController private authorityIssuerController;

function AuthorityIssuerControllerTest
(
    address authorityIssuerControllerAddress
)
public
{
    authorityIssuerController=AuthorityIssuerController(authorityIssuerControllerAddress);
}

/*
函数用途：测试新增AuthorityIssuer功能
参数：
    addr：新增authorityIssuer的地址
    attribBytes32：名字
    attribInt：创建日期
    accValue：值（预留，目前无用）
返回值：无
*/
function addAuthorityTest
    (
        address addr,
        bytes32[16] attribBytes32,
        int[16] attribInt,
        bytes accValue
    )
    public
    {
        authorityIssuerController.addAuthorityIssuer(addr,attribBytes32,attribInt,accValue);
    }

/*
函数用途：测试签名交易功能
参数：
   transactionId：需要签名的交易id
返回值：无
*/  
    function signTransactionTest
    (
        uint transactionId
    )
    public
    {
        authorityIssuerController.signTransaction(transactionId);
    }
    
/*
函数用途：测试获取当前所有需要被多签的交易功能
参数：无
返回值：无
*/  
    function getPendingTranTest()public{
        authorityIssuerController.getPendingTransactions();
    }

/*
函数用途：测试设置某交易ID的多签要求数量功能
参数：
   transactionId：需要设置的交易id
   minNumber：要求的多签数量
返回值：无
*/   
    function setTxIDMultiSigTest
    (
         uint transactionId,
         uint minNumber
    )
    public
    {
        authorityIssuerController.setTxIDMultiSig(transactionId,minNumber);
    }

/*
函数用途：测试获取某交易还需要的签名数量功能
参数：
   transactionId：要查询的交易id
返回值：无
*/  
    function getTxIDNeedMultiSigNumTest
    (
         uint transactionId    
    )
    public{
        authorityIssuerController.getTxIDNeedMultiSigNum(transactionId);
    }
    
}