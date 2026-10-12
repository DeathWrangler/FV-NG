package Classes.util
{
   public class LoadPhase
   {
      
      private var m_name:String;
      
      private var m_mark:Boolean = false;
      
      public function LoadPhase(name:String)
      {
         super();
         this.m_name = name;
      }
      
      public function get name() : String
      {
         return this.m_name;
      }
      
      internal function mark() : void
      {
         this.m_mark = true;
      }
      
      public function isMarked() : Boolean
      {
         return this.m_mark;
      }
   }
}

