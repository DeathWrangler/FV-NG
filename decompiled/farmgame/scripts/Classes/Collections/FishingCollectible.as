package Classes.Collections
{
   import Classes.GameSettingsObject;
   import Classes.ZItem.FarmItem;
   
   public class FishingCollectible extends GameSettingsObject
   {
      
      public static const FISHING_ICON_PREFIX:String = "assets/animals/fishing/fishing_";
      
      public static const FISHING_ICON_POSTFIX:String = ".png";
      
      private var m_rarity:String;
      
      private var m_masterySignName:String;
      
      private var m_collectionName:String;
      
      public function FishingCollectible(xml:XML, collectionName:String = "")
      {
         super(xml);
         this.m_rarity = String(xml.@rarity);
         this.m_masterySignName = String(xml.@masterySign);
         this.m_collectionName = collectionName;
      }
      
      public function get assetPath() : String
      {
         var result:String = null;
         var farmItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(name);
         if(farmItem != null)
         {
            result = farmItem.icon;
         }
         else
         {
            result = FISHING_ICON_PREFIX + name + FISHING_ICON_POSTFIX;
         }
         return result;
      }
      
      public function get rarity() : String
      {
         return this.m_rarity;
      }
      
      public function get masterySignName() : String
      {
         return this.m_masterySignName;
      }
      
      public function get collectionName() : String
      {
         return this.m_collectionName;
      }
   }
}

