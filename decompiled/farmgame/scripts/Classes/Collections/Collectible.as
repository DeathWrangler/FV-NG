package Classes.Collections
{
   import Classes.Constants.CollectionsConstants;
   import Classes.GameSettingsObject;
   import Classes.ZItem.FarmItem;
   import Managers.CollectionsManager;
   import Managers.FarmGameSettingsManager;
   
   public class Collectible extends GameSettingsObject
   {
      
      public static const RARITY_NUM_RARE:int = 2;
      
      public static const RARITY_NUM_UNCOMMON:int = 1;
      
      public static const RARITY_NUM_COMMON:int = 0;
      
      public static const COLLECTIBLES_NEEDED:Number = 3;
      
      protected var m_item:FarmItem = null;
      
      protected var m_cash:Number = 0;
      
      public function Collectible(xml:XML)
      {
         super(xml);
      }
      
      public function get code() : String
      {
         return m_xml.@code;
      }
      
      public function get source() : String
      {
         return m_xml.@source;
      }
      
      public function get rarityString() : String
      {
         return m_xml.@rarity;
      }
      
      public function get rarityStringFriendlyName() : String
      {
         var result:String = "";
         var collectRarity:String = this.rarityString;
         return "Collections:" + collectRarity + "_friendlyName";
      }
      
      public function get rarityNumber() : Number
      {
         var result:Number = 0;
         var collectRarity:String = this.rarityString;
         if(collectRarity == CollectionsConstants.RARITY_UNCOMMON)
         {
            result = RARITY_NUM_UNCOMMON;
         }
         else if(collectRarity == CollectionsConstants.RARITY_RARE)
         {
            result = RARITY_NUM_RARE;
         }
         else
         {
            result = RARITY_NUM_COMMON;
         }
         return result;
      }
      
      override public function get friendlyName() : String
      {
         var result:String = null;
         var farmItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByCode(this.code);
         if(farmItem)
         {
            result = farmItem.friendlyName;
         }
         else
         {
            result = super.friendlyName;
         }
         return result;
      }
      
      public function get numNeeded() : Number
      {
         var result:Number = NaN;
         var collection:Collection = null;
         if(m_xml.@numneeded != null && m_xml.@numneeded > 0)
         {
            result = Number(m_xml.@numneeded);
         }
         else
         {
            collection = CollectionsManager.getInstance().getCollectionByCollectibleCode(this.code);
            result = (COLLECTIBLES_NEEDED - this.rarityNumber) * (collection.getLevel() + 1);
         }
         return result;
      }
      
      public function get numOwned() : Number
      {
         if(Global.player.collectionCounters[this.code] == null)
         {
            Global.player.collectionCounters[this.code] = 0;
         }
         return Global.player.collectionCounters[this.code];
      }
      
      public function get item() : FarmItem
      {
         if(null == this.m_item)
         {
            this.m_item = Global.farmGameSettingsManager.getFarmItemByCode(this.code);
         }
         return this.m_item;
      }
      
      public function get cashCost() : Number
      {
         var newItem:FarmItem = null;
         if(this.m_cash <= 0)
         {
            newItem = Global.farmGameSettingsManager.getFarmItemByCode(this.code);
            if(newItem != null)
            {
               if(FarmGameSettingsManager.isInDataSourceExperiment())
               {
                  this.m_cash = newItem.getNumberFromDataSource("cash");
               }
               else
               {
                  this.m_cash = newItem.xml.cash;
               }
            }
         }
         return this.m_cash;
      }
   }
}

