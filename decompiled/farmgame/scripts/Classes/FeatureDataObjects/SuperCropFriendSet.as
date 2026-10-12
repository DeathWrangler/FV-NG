package Classes.FeatureDataObjects
{
   import Classes.ItemRequirement;
   import Classes.SuperCropRequirement;
   import Classes.ZItem.FarmItem;
   import Engine.Managers.TransactionManager;
   import Transactions.TInitializeSuperCropsFriendSet;
   import flash.events.Event;
   
   public class SuperCropFriendSet extends FriendSet
   {
      
      private var m_cropCode:String;
      
      private var m_friendGoal:int = -1;
      
      public function SuperCropFriendSet(code:String, cropCode:String, callback:Function = null)
      {
         this.m_cropCode = cropCode;
         super(code,-2,callback);
      }
      
      public function get cropCode() : String
      {
         return this.m_cropCode;
      }
      
      public function get friendGoal() : int
      {
         var farmItem:FarmItem = null;
         var requirement:ItemRequirement = null;
         if(-1 == this.m_friendGoal)
         {
            farmItem = Global.farmGameSettingsManager.getFarmItemByCode(this.m_cropCode);
            for each(requirement in farmItem.requirements)
            {
               if(requirement is SuperCropRequirement)
               {
                  this.m_friendGoal = (requirement as SuperCropRequirement).friendsRequired;
               }
            }
         }
         return this.m_friendGoal;
      }
      
      override public function getDifficultyForLevel(level:int, min:int, max:int) : int
      {
         return this.m_friendGoal > max ? max : this.m_friendGoal;
      }
      
      override public function initializeData() : void
      {
         TransactionManager.addTransaction(new TInitializeSuperCropsFriendSet(this),true);
      }
      
      override public function onInitialize(result:Object) : void
      {
         if(result.error)
         {
            if(m_callback != null)
            {
               m_callback(this,result);
            }
            dispatchEvent(new Event(Event.COMPLETE));
         }
         else
         {
            this.index = result.index;
            super.onInitialize(result);
         }
      }
      
      override public function get className() : String
      {
         return FriendSet.SUPER_CROP_FRIEND_SET;
      }
   }
}

