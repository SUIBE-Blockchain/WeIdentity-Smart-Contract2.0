pragma solidity ^0.4.4;
/*
 *       Copyright© (2018-2019) WeBank Co., Ltd.
 *
 *       This file is part of weidentity-contract.
 *
 *       weidentity-contract is free software: you can redistribute it and/or modify
 *       it under the terms of the GNU Lesser General Public License as published by
 *       the Free Software Foundation, either version 3 of the License, or
 *       (at your option) any later version.
 *
 *       weidentity-contract is distributed in the hope that it will be useful,
 *       but WITHOUT ANY WARRANTY; without even the implied warranty of
 *       MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *       GNU Lesser General Public License for more details.
 *
 *       You should have received a copy of the GNU Lesser General Public License
 *       along with weidentity-contract.  If not, see <https://www.gnu.org/licenses/>.
 */

import "./AuthorityIssuerData.sol";
import "./RoleController.sol";

/**
 * @title AuthorityIssuerController
 * Issuer contract manages authority issuer info.
 */

contract AuthorityIssuerController {

    AuthorityIssuerData private authorityIssuerData;
    RoleController private roleController;
     //---------updated begin----------
    uint private transactionIdx;
    uint[] private pendingTransactions;
    mapping (uint => Transaction) private transactions;
     //---------updated end----------
    
     //---------updated begin----------
    //等待状态的交易结构
    struct Transaction {
        address from;
        uint signatureCount;
        uint minNumber;
        mapping (address => uint) signatures;
        address addr;
        bytes32[16] attribBytes32;
        int[16] attribInt;
        bytes accValue;
        bool isCreated;
    }
    //---------updated end----------
    
    // Event structure to store tx records
    uint constant private OPERATION_ADD = 0;
    uint constant private OPERATION_REMOVE = 1;
    uint constant private EMPTY_ARRAY_SIZE = 1;

    event AuthorityIssuerRetLog(uint operation, uint retCode, address addr);
     //---------updated begin----------
    event TransactionIdLog(uint id);//用于显示处于等待状态的交易序号
    event signTransactionLog(uint id,uint neednumber);
    event getPendingTransactionsLog(uint [] pendingTransactions);
    event errorLog(string error);
     //---------updated end----------


    // Constructor.
    function AuthorityIssuerController(
        address authorityIssuerDataAddress,
        address roleControllerAddress
    ) 
        public 
    {
        authorityIssuerData = AuthorityIssuerData(authorityIssuerDataAddress);
        roleController = RoleController(roleControllerAddress);
    }

/*
函数用途：新增AuthorityIssuer
参数：
    addr：新增authorityIssuer的地址
    attribBytes32：名字
    attribInt：创建日期
    accValue：值（预留，目前无用）
返回值：无
*/
    function addAuthorityIssuer(
        address addr,
        bytes32[16] attribBytes32,
        int[16] attribInt,
        bytes accValue
        
    )
        public
    {
        if (!roleController.checkPermission(tx.origin, roleController.MODIFY_AUTHORITY_ISSUER())) {
            AuthorityIssuerRetLog(OPERATION_ADD, roleController.RETURN_CODE_FAILURE_NO_PERMISSION(), addr);
            return;
        }
        
         //---------updated begin----------
        uint transactionId = transactionIdx++;
        Transaction memory transaction;
        transaction.signatureCount = 0;
        transaction.minNumber=0;
        transaction.from=msg.sender;
        transaction.addr=addr;
        transaction.attribBytes32=attribBytes32;
        transaction.attribInt=attribInt;
        transaction.accValue=accValue;
        transaction.isCreated=true;
        transactions[transactionId] = transaction;
        pendingTransactions.push(transactionId);
        TransactionIdLog(transactionId);
         //---------updated end----------
    }
    
     //---------updated begin----------
    
/*
函数用途：设置某交易ID的多签要求数量
参数：
   transactionId：需要设置的交易id
   minNumber：要求的多签数量
返回值：无
*/    
     function setTxIDMultiSig
     (
         uint transactionId,
         uint minNumber
     )
     public
     {
        if (!roleController.checkPermission(tx.origin, roleController.MODIFY_COMMITTEE())) {
            return;
        }
        
         Transaction storage transaction = transactions[transactionId];
         
        if (transaction.isCreated==false){
            errorLog("the transaction haven't created");
            return;
        }
         transaction.minNumber=minNumber;
         signTransactionLog(transactionId,minNumber);
         
     }

/*
函数用途：获取某交易还需要的签名数量
参数：
   transactionId：要查询的交易id
返回值：
    类型：uint
    说明：该交易还需要的签名数量
*/  
     function getTxIDNeedMultiSigNum
     (
         uint transactionId
     )
     public returns(uint)
     {
         Transaction storage transaction = transactions[transactionId];
         if(transaction.minNumber==0){
             errorLog("You haven't set the MuliSigNumber of this transactionID yet");
             return 0;
         }else{
         signTransactionLog(transactionId,transaction.minNumber-transaction.signatureCount);
         return transaction.minNumber-transaction.signatureCount;
         }
     }

/*
函数用途：签名某交易
参数：
   transactionId：需要签名的交易id
返回值：无
*/  
     function signTransaction(
         uint transactionId
         )
        public
        {
        Transaction storage transaction = transactions[transactionId];
        //检查是否有权限
        if (!roleController.checkPermission(tx.origin, roleController.MODIFY_AUTHORITY_ISSUER())) {
            return;
        }
        require(transaction.signatures[tx.origin]!=1);
        transaction.signatures[tx.origin] = 1;
        transaction.signatureCount++;
        if(transaction.minNumber==0){
            errorLog("You haven't set the MuliSigNumber of this transactionID yet");
            return;
        }
        if(transaction.signatureCount >= transaction.minNumber){
          uint result = authorityIssuerData.addAuthorityIssuerFromAddress(transaction.addr,transaction.attribBytes32, transaction.attribInt, transaction.accValue);
          AuthorityIssuerRetLog(OPERATION_ADD, result, transaction.addr);
          deleteTransaction(transactionId);//将处理完的交易从等待交易队列中删除
        }else{
            signTransactionLog(transactionId,transaction.minNumber-transaction.signatureCount);
        }
    }

/*
函数用途：删除已被多签完成的交易
参数：
   transactionId：需要被删除的交易id
返回值：无
*/  
   
    function deleteTransaction(uint transacionId) public{
        uint replace = 0;
        for(uint i = 0; i< pendingTransactions.length; i++){
            if(1==replace){
                pendingTransactions[i-1] = pendingTransactions[i];
            }else if(transacionId == pendingTransactions[i]){
                replace = 1;
            }
        } 
        delete pendingTransactions[pendingTransactions.length - 1];
        pendingTransactions.length--;
        delete transactions[transacionId];
    }

/*
函数用途：获取当前所有需要被多签的交易
参数：无
返回值：无
*/  
    function getPendingTransactions() public view returns(uint[]){
        getPendingTransactionsLog(pendingTransactions);
        return pendingTransactions;
    }
    
     //---------updated end----------

    function removeAuthorityIssuer(
        address addr
    ) 
        public 
    {
        if (!roleController.checkPermission(tx.origin, roleController.MODIFY_AUTHORITY_ISSUER())) {
            AuthorityIssuerRetLog(OPERATION_REMOVE, roleController.RETURN_CODE_FAILURE_NO_PERMISSION(), addr);
            return;
        }
        uint result = authorityIssuerData.deleteAuthorityIssuerFromAddress(addr);
        AuthorityIssuerRetLog(OPERATION_REMOVE, result, addr);
    }

    function getAuthorityIssuerAddressList(
        uint startPos,
        uint num
    ) 
        public 
        constant 
        returns (address[]) 
    {
        uint totalLength = authorityIssuerData.getDatasetLength();

        uint dataLength;
        // Calculate actual dataLength
        if (totalLength < startPos) {
            return new address[](EMPTY_ARRAY_SIZE);
        } else if (totalLength <= startPos + num) {
            dataLength = totalLength - startPos;
        } else {
            dataLength = num;
        }

        address[] memory issuerArray = new address[](dataLength);
        for (uint index = 0; index < dataLength; index++) {
            issuerArray[index] = authorityIssuerData.getAuthorityIssuerFromIndex(startPos + index);
        }
        return issuerArray;
    }

    function getAuthorityIssuerInfoNonAccValue(
        address addr
    )
        public
        constant
        returns (bytes32[], int[])
    {
        // Due to the current limitations of bcos web3j, return dynamic bytes32 and int array instead.
        bytes32[16] memory allBytes32;
        int[16] memory allInt;
        (allBytes32, allInt) = authorityIssuerData.getAuthorityIssuerInfoNonAccValue(addr);
        bytes32[] memory finalBytes32 = new bytes32[](16);
        int[] memory finalInt = new int[](16);
        for (uint index = 0; index < 16; index++) {
            finalBytes32[index] = allBytes32[index];
            finalInt[index] = allInt[index];
        }
        return (finalBytes32, finalInt);
    }

    function isAuthorityIssuer(
        address addr
    ) 
        public 
        constant 
        returns (bool) 
    {
        return authorityIssuerData.isAuthorityIssuer(addr);
    }
}


