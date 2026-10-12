package com.troyer.widget.parser
{
   public class ParserErrorList
   {
      
      private var m_errors:Array;
      
      private var m_numErrors:int;
      
      private var m_numWarnings:int;
      
      public function ParserErrorList()
      {
         super();
         this.m_errors = new Array();
      }
      
      public function addError(param1:String) : void
      {
         this.m_errors.push(new ParserError(param1,ParserError.ERROR));
         ++this.m_numErrors;
      }
      
      public function addWarning(param1:String) : void
      {
         this.m_errors.push(new ParserError(param1,ParserError.WARNING));
         ++this.m_numWarnings;
      }
      
      public function errors() : Array
      {
         return this.m_errors;
      }
      
      public function get numErrors() : int
      {
         return this.m_numErrors;
      }
      
      public function get numWarnings() : int
      {
         return this.m_numWarnings;
      }
      
      public function toString() : String
      {
         var _loc2_:ParserError = null;
         var _loc1_:String = "";
         for each(_loc2_ in this.m_errors)
         {
            if(_loc2_.errorType == ParserError.ERROR)
            {
               _loc1_ = _loc1_ + "ERROR: " + _loc2_.error + "\n";
            }
            else
            {
               _loc1_ = _loc1_ + "WARNING: " + _loc2_.error + "\n";
            }
         }
         return _loc1_;
      }
   }
}

