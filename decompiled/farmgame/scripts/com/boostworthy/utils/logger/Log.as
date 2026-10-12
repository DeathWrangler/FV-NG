package com.boostworthy.utils.logger
{
   public class Log implements ILog
   {
      
      protected var m_strName:String;
      
      protected var m_uLevel:uint;
      
      public function Log(param1:String, param2:uint)
      {
         super();
         this.init(param1,param2);
      }
      
      public function getName() : String
      {
         return this.m_strName;
      }
      
      public function getLevel() : uint
      {
         return this.m_uLevel;
      }
      
      public function setLevel(param1:uint) : void
      {
         this.m_uLevel = param1;
      }
      
      public function severe(param1:String) : void
      {
         this.output(param1,LogLevel.SEVERE);
      }
      
      public function warning(param1:String) : void
      {
         this.output(param1,LogLevel.WARNING);
      }
      
      public function info(param1:String) : void
      {
         this.output(param1,LogLevel.INFO);
      }
      
      public function debug(param1:String) : void
      {
         this.output(param1,LogLevel.DEBUG);
      }
      
      protected function init(param1:String, param2:uint) : void
      {
         this.m_strName = param1;
         this.m_uLevel = param2;
      }
      
      protected function getLevelName(param1:uint) : String
      {
         switch(param1)
         {
            case LogLevel.OFF:
               return "OFF";
            case LogLevel.SEVERE:
               return "SEVERE";
            case LogLevel.WARNING:
               return "WARNING";
            case LogLevel.INFO:
               return "INFO";
            case LogLevel.DEBUG:
               return "DEBUG";
            default:
               return "";
         }
      }
      
      protected function output(param1:String, param2:uint) : void
      {
         if(!(this.m_uLevel & LogLevel.OFF) && this.m_uLevel >= param2)
         {
         }
      }
      
      protected function createOutputMessage(param1:String, param2:uint) : String
      {
         return this.m_strName + " (" + this.getLevelName(param2) + ") :: " + param1 + "\n";
      }
   }
}

