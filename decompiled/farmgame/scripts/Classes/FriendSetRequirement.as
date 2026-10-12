package Classes
{
   import Classes.FeatureDataObjects.FriendSet;
   import Classes.ZItem.FarmItem;
   import Classes.ZItem.FarmItemLock;
   import Classes.util.ZLocUtils;
   import DataSources.BaseDataSource;
   import Managers.PartyManager;
   
   public class FriendSetRequirement extends ItemRequirement
   {
      
      private var m_friendSetCode:String;
      
      private var m_targetAmount:int;
      
      private var m_friendCount:int = 0;
      
      private var m_dialogName:String = null;
      
      public function FriendSetRequirement(xml:XML, item:FarmItem, dataSource:BaseDataSource = null)
      {
         super(xml,item,dataSource);
         if(m_dataSource)
         {
            this.m_friendSetCode = m_dataSource.getString("code");
            this.m_targetAmount = m_dataSource.getInt("amount");
            this.m_dialogName = m_dataSource.getString("dialog");
         }
         else
         {
            this.m_friendSetCode = xml.@code;
            this.m_targetAmount = xml.@amount;
            this.m_dialogName = xml.@dialog;
         }
      }
      
      override public function check() : Boolean
      {
         var result:Boolean = false;
         var friendSet:FriendSet = PartyManager.getInstance().getPartyObjectByCode(this.m_friendSetCode).friendSet;
         if(friendSet)
         {
            this.m_friendCount = friendSet.numFriendsCompleted;
            if(this.m_friendCount >= this.m_targetAmount)
            {
               result = true;
            }
         }
         return result;
      }
      
      override public function get identifier() : String
      {
         return FarmItemLock.FRIEND_SET;
      }
      
      override public function getMarketUnlockString() : String
      {
         return ZLocUtils.t("Dialogs","Surveyor_GetMore");
      }
      
      override public function getReadableMessage() : String
      {
         return ZLocUtils.t("Dialogs","Surveyor_tooltip",{
            "quantity":this.m_friendCount,
            "maximum":this.m_targetAmount
         });
      }
      
      public function get friendSetCode() : String
      {
         return this.m_friendSetCode;
      }
      
      public function get targetAmount() : int
      {
         return this.m_targetAmount;
      }
      
      public function get dialogName() : String
      {
         return this.m_dialogName;
      }
   }
}

