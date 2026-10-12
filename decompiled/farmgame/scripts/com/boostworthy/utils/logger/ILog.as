package com.boostworthy.utils.logger
{
   public interface ILog
   {
      
      function getName() : String;
      
      function getLevel() : uint;
      
      function setLevel(param1:uint) : void;
      
      function severe(param1:String) : void;
      
      function warning(param1:String) : void;
      
      function info(param1:String) : void;
      
      function debug(param1:String) : void;
   }
}

