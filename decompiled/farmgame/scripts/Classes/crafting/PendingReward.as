package Classes.crafting
{
   public class PendingReward
   {
      
      private var m_visitorUid:String;
      
      private var m_claimed:Boolean;
      
      private var m_time:Number;
      
      private var m_count:int;
      
      public function PendingReward()
      {
         super();
      }
      
      public function get visitorUid() : String
      {
         return this.m_visitorUid;
      }
      
      public function set visitorUid(newVisitorUid:String) : void
      {
         this.m_visitorUid = newVisitorUid;
      }
      
      public function get time() : Number
      {
         return this.m_time;
      }
      
      public function set time(newTime:Number) : void
      {
         this.m_time = newTime;
      }
      
      public function get claimed() : Boolean
      {
         return this.m_claimed;
      }
      
      public function set claimed(newClaimed:Boolean) : void
      {
         this.m_claimed = newClaimed;
      }
      
      public function set count(newCount:int) : void
      {
         this.m_count = newCount;
      }
      
      public function get count() : int
      {
         return this.m_count;
      }
   }
}

