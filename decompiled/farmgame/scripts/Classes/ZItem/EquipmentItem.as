package Classes.ZItem
{
   import DataSources.BaseDataSource;
   import GameMode.GMBuild;
   import GameMode.GMEquipmentPlace;
   import Managers.FarmGameSettingsManager;
   
   public class EquipmentItem extends DecorationItem
   {
      
      protected static const m_defaultTerrains:Array = new Array(FarmGameSettingsManager.TERRAIN_LAND,FarmGameSettingsManager.TERRAIN_UNDERWATER,FarmGameSettingsManager.TERRAIN_TURTLE,FarmGameSettingsManager.TERRAIN_DREAM,FarmGameSettingsManager.TERRAIN_EARTH);
      
      private var m_requiredMafiaLevel:Number = -559038227;
      
      private var m_requiredMafiaLevelChange:Number = -559038227;
      
      private var m_mafiaUrl:String = null;
      
      public function EquipmentItem(itemXML:XML = null, itemData:BaseDataSource = null)
      {
         super(itemXML,itemData);
      }
      
      override protected function onConstruction(itemXML:XML, itemData:BaseDataSource) : void
      {
         super.onConstruction(itemXML,itemData);
      }
      
      override protected function getDefaultTerrains() : Array
      {
         return EquipmentItem.m_defaultTerrains;
      }
      
      public function get requiredMafiaLevel() : Number
      {
         if(this.m_requiredMafiaLevel == INVALID_VALUE)
         {
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               this.m_requiredMafiaLevel = m_dataSource.getNumber("requiredMafiaLevel");
            }
            else
            {
               this.m_requiredMafiaLevel = Number(m_itemXML.@requiredMafiaLevel);
            }
         }
         return this.m_requiredMafiaLevel;
      }
      
      public function get requiredMafiaLevelChange() : Number
      {
         if(this.m_requiredMafiaLevelChange == INVALID_VALUE)
         {
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               this.m_requiredMafiaLevelChange = m_dataSource.getNumber("requiredMafiaLevelChange");
            }
            else
            {
               this.m_requiredMafiaLevelChange = Number(m_itemXML.@requiredMafiaLevelChange);
            }
         }
         return this.m_requiredMafiaLevelChange;
      }
      
      public function get mafiaUrl() : String
      {
         if(this.m_mafiaUrl == null)
         {
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               this.m_mafiaUrl = m_dataSource.getString("mafiaUrl");
            }
            else
            {
               this.m_mafiaUrl = m_itemXML.@mafiaUrl;
            }
         }
         return this.m_mafiaUrl;
      }
      
      override public function onBuy(name:String, extraData:Object = null) : Boolean
      {
         var numParts:int = 0;
         var currency:String = "";
         if(Boolean(extraData) && extraData.hasOwnProperty("currency"))
         {
            currency = extraData.currency;
         }
         if(subType == "building")
         {
            Global.world.addGameMode(new GMBuild(name,false,0,true,extraData,currency));
         }
         else
         {
            numParts = getNumberOfParts();
            Global.world.addGameMode(new GMEquipmentPlace(name,false,0,numParts,extraData.currency));
         }
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
         var itemCount:int = 1;
         if(Boolean(extraData) && extraData["itemCount"] > 0)
         {
            itemCount = int(extraData["itemCount"]);
         }
         var numParts:int = getNumberOfParts();
         Global.world.addGameMode(new GMEquipmentPlace(itemName,isGift,buildingId,numParts,extraData.currency));
      }
      
      override protected function defaultPreview() : Boolean
      {
         return true;
      }
   }
}

