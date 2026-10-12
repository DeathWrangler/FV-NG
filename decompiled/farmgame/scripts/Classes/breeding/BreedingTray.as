package Classes.breeding
{
   public class BreedingTray
   {
      
      protected var m_projectInfo:Object;
      
      public function BreedingTray(projectInfo:Object)
      {
         super();
         this.m_projectInfo = projectInfo;
      }
      
      public function get helpingFriends() : Array
      {
         return this.m_projectInfo.helpingFriendIds;
      }
      
      public function get ingredients() : Object
      {
         return this.m_projectInfo.itemIngredients;
      }
      
      public function get startTime() : String
      {
         return this.m_projectInfo.startTime;
      }
      
      public function get purchasedHelp() : int
      {
         return this.m_projectInfo.purchaseHelp;
      }
      
      public function set purchasedHelp(newVal:int) : void
      {
         this.m_projectInfo.purchaseHelp = newVal;
      }
      
      public function getNumDaysReduced() : int
      {
         return this.purchasedHelp + this.helpingFriends.length;
      }
      
      public function getQuantityProduced() : int
      {
         return 50;
      }
      
      public function get resultItemCode() : String
      {
         return this.m_projectInfo.itemCode;
      }
   }
}

