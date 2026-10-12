package Classes
{
   public class RecentItems
   {
      
      public static var GIFT_ITEMS_RECENT_LIMIT:int = 18;
      
      private var m_recent:Array;
      
      private var m_maxLimit:int;
      
      public function RecentItems(maxLimit:int = 18)
      {
         super();
         this.m_maxLimit = maxLimit;
         this.m_recent = new Array();
      }
      
      private function printRecentList() : void
      {
         var arrLength:int = int(this.m_recent.length);
         for(var i:int = 0; i < arrLength; i++)
         {
         }
      }
      
      public function addRecent(item:String) : void
      {
         var flag:int = -1;
         if(this.m_recent)
         {
            flag = this.m_recent.indexOf(item);
         }
         if(flag != -1)
         {
            this.m_recent.splice(flag,1);
            this.m_recent.push(item);
         }
         else
         {
            this.m_recent.push(item);
         }
         if(this.m_recent.length > this.m_maxLimit)
         {
            this.m_recent.shift();
         }
      }
      
      public function getRecentItems() : Array
      {
         return this.m_recent;
      }
   }
}

