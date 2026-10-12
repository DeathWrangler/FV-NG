package Classes
{
   public class PrereqDrivenWindowComponent
   {
      
      private var m_prefix:String;
      
      private var m_suffix:String;
      
      private var m_start:int;
      
      private var m_end:int;
      
      private var m_breakOnTrue:Boolean;
      
      public function PrereqDrivenWindowComponent(prefix:String, suffix:String, start:int, end:int, breakOnTrue:Boolean = false)
      {
         super();
         this.m_prefix = prefix;
         this.m_suffix = suffix;
         this.m_start = start;
         this.m_end = end;
         this.m_breakOnTrue = breakOnTrue;
      }
      
      public function get prefix() : String
      {
         return this.m_prefix;
      }
      
      public function get suffix() : String
      {
         return this.m_suffix;
      }
      
      public function get start() : int
      {
         return this.m_start;
      }
      
      public function get end() : int
      {
         return this.m_end;
      }
      
      public function get breakOnTrue() : Boolean
      {
         return this.m_breakOnTrue;
      }
   }
}

