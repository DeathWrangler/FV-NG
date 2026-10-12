package Classes.ZItem
{
   import Classes.MutableDragon;
   import DataSources.BaseDataSource;
   import GameMode.GMAnimalPlace;
   import Managers.FarmGameSettingsManager;
   
   public class MutableDragonItem extends AnimalItem
   {
      
      public function MutableDragonItem(itemXML:XML = null, itemData:BaseDataSource = null)
      {
         super(itemXML,itemData);
      }
      
      override public function onBuy(name:String, extraData:Object = null) : Boolean
      {
         var currency:String = Boolean(extraData) && extraData.hasOwnProperty("currency") ? extraData.currency : "";
         Global.world.addGameMode(new GMAnimalPlace(name,false,0,false,MutableDragon,currency));
         return true;
      }
      
      public function getShareableItemCode() : String
      {
         var itemCode:String = null;
         var itemName:String = null;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            if(m_dataSource.hasProperty("shareFeedRewardItem"))
            {
               itemName = m_dataSource.getString("shareFeedRewardItem");
            }
         }
         else if(m_itemXML.hasOwnProperty("shareFeedRewardItem"))
         {
            itemName = m_itemXML.shareFeedRewardItem;
         }
         if(itemName)
         {
            itemCode = Global.farmGameSettingsManager.getFarmItemCodeByName(itemName);
         }
         return itemCode;
      }
   }
}

