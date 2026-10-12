package Classes.ZItem
{
   import Classes.SimpleHarvestableItem;
   import DataSources.BaseDataSource;
   import Engine.Managers.TransactionManager;
   import GameMode.GMPlantTree;
   import Managers.FarmGameSettingsManager;
   import Transactions.TBuyConsumables;
   
   public class TreeItem extends SimpleHarvestableItem
   {
      
      private var m_nextLevel:String = null;
      
      public function TreeItem(itemXML:XML = null, itemData:BaseDataSource = null)
      {
         super(itemXML,itemData);
      }
      
      override public function onBuy(name:String, extraData:Object = null) : Boolean
      {
         var currency:String = "";
         if(Boolean(extraData) && extraData.hasOwnProperty("currency"))
         {
            currency = extraData["currency"];
         }
         if(subType == "consumable")
         {
            TransactionManager.addTransaction(new TBuyConsumables(name,false));
         }
         else
         {
            Global.world.addGameMode(new GMPlantTree(name,false,0,true,currency));
         }
         patchTime = GlobalEngine.serverTime;
         return true;
      }
      
      override public function onUse(buildingId:int = 0, extraData:Object = null) : void
      {
         var isGift:Boolean = true;
         if(Boolean(extraData) && Boolean(extraData.isGift != null) && extraData.isGift == false)
         {
            isGift = false;
         }
         var itemName:String = name;
         if(Boolean(extraData) && extraData.realItemName != null)
         {
            itemName = extraData.realItemName;
         }
         var shouldReopenGift:Boolean = isToolGenerated ? false : true;
         Global.world.addGameMode(new GMPlantTree(itemName,isGift,buildingId,shouldReopenGift));
         patchTime = GlobalEngine.serverTime;
      }
      
      override protected function defaultPreview() : Boolean
      {
         return subType != "consumable";
      }
      
      public function get nextLevel() : String
      {
         if(this.m_nextLevel == null)
         {
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               this.m_nextLevel = getDataProperty(m_dataSource,"nextLevel");
            }
            else
            {
               this.m_nextLevel = getXMLProperty(m_itemXML,"nextLevel");
            }
         }
         return this.m_nextLevel;
      }
   }
}

