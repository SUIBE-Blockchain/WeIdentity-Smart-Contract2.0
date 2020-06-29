pragma solidity ^0.4.4;

contract CredentialController{
    
    mapping (uint=>uint) private cptNumber;
    mapping (uint=>uint) private creidrandNum;
    mapping (uint=>uint) private cptLimit;
    uint Creid;
    uint randNonce = 0;
    
    event limitNumberLog(uint cptid,uint limitNum,uint IssueNumber);
    event IdAndRandLog(uint creid,uint randNum);
    event limitLog(uint cptid,uint limitNum);
    

/*
函数用途：设置某类型cpt的可发行的限量数额
参数：
    cptid：要使用的 cpt 的编号
    limitNum：该类型 cpt 限量发行的额数
返回值：无
*/ 
   function setLimit
   (
    uint cptid,
    uint limitNum   
    )
    public
    {
        cptLimit[cptid]=limitNum;
        limitLog(cptid,limitNum);
    }

/*
函数用途：获取某类型cpt的可发行的限量数额以及已发行的credential数量
参数：
    cptid：要获取的 cpt 的编号
返回值：
    类型：uint，uint
    说明：某类型cpt的可发行的限量数额，已发行该类型credential的数量
*/ 
    function getCptILimitAndIssuedNum
    (
    uint cptid
    )
    public
    returns(uint,uint)
    {
        limitNumberLog(cptid,cptLimit[cptid],cptNumber[cptid]);
        return (cptLimit[cptid],cptNumber[cptid]);
    }


    
/*
函数用途：生成credentialID号与随机数
参数：
    cptid：要获取的 cpt 的编号
返回值：
    类型：uint，uint
    说明：生成的credentialID号与随机数

*/    
    function generateIdAndRandNum
    (
        uint cptid
    )
    public 
    returns(uint,uint)
    {
          if(cptNumber[cptid]<cptLimit[cptid]){
              cptNumber[cptid]++;
              Creid++;
              for(uint randNum = uint(keccak256(now, msg.sender, randNonce)) % 10000;randNum==0;){
                 randNum=uint(keccak256(now, msg.sender, randNonce)) % 10000;
              }
              randNonce++;
              creidrandNum[cptNumber[cptid]]=randNum;
              IdAndRandLog(Creid,randNum);
              return(Creid,randNum);
          } 
          else{
              IdAndRandLog(0,0);
              return (0,0);//error
          }
            
    }

/*
函数用途：获取某crendential生成的随机数
参数：
    creid：要使用的credential的ID号
返回值：
    类型：uint
    说明：该credential的随机数
*/ 
    function getRandNumOfCreid
    (
        uint creid
    )
    public
    returns (uint)
    {
        IdAndRandLog(creid,creidrandNum[creid]);
        return creidrandNum[creid];
    }
    
   
    
}