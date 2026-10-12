package Classes.Doobers
{
   import Classes.FarmGameObject;
   import Classes.ItemInstance;
   import Classes.ZItem.FarmItem;
   import Managers.FarmGameSettingsManager;
   
   public class DooberCoinYieldReward extends DooberReward
   {
      
      public function DooberCoinYieldReward(rewardXml:XML, actionObject:FarmGameObject)
      {
         super(rewardXml,actionObject);
         m_amount = NO_AMOUNT_SET;
      }
      
      override public function getAmount() : int
      {
         var curItem:FarmItem = null;
         var result:int = super.getAmount();
         if(m_amount == NO_AMOUNT_SET)
         {
            if(m_actionObject is ItemInstance)
            {
               curItem = (m_actionObject as ItemInstance).getItem();
               if(FarmGameSettingsManager.isInDataSourceExperiment())
               {
                  result = curItem.getIntFromDataSource("coinYield");
               }
               else
               {
                  result = int(curItem.xml.coinYield);
               }
               m_amount = result;
            }
         }
         return result;
      }
      
      override public function isAvailable() : Boolean
      {
         return this.getAmount() > 0 && Boolean(super.isAvailable());
      }
   }
}

