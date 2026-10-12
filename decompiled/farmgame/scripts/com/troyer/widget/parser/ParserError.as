package com.troyer.widget.parser
{
   public class ParserError
   {
      
      public static const ERROR:String = "error";
      
      public static const WARNING:String = "warning";
      
      private var m_error:String;
      
      private var m_errorType:String;
      
      public function ParserError(param1:String, param2:String)
      {
         super();
         this.m_error = param1;
         this.m_errorType = param2;
      }
      
      public function get error() : String
      {
         return this.m_error;
      }
      
      public function get errorType() : String
      {
         return this.m_errorType;
      }
   }
}

