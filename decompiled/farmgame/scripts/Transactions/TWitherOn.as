package Transactions
{
   import Classes.ItemInstance;
   import Classes.Terrain.TerrainUtil;
   import Classes.ZItem.FarmItem;
   import Engine.Classes.WorldObject;
   import Managers.WorldSeasonsManager;
   
   public class TWitherOn extends TFarmTransaction
   {
      
      private var m_itemId:int = 0;
      
      private var m_item:FarmItem = null;
      
      public function TWitherOn(itemId:int, item:FarmItem)
      {
         super();
         this.m_itemId = itemId;
         this.m_item = item;
      }
      
      override public function perform() : void
      {
         signedCall("UserService.toggleWither",this.m_itemId);
      }
      
      override protected function onComplete(result:Object) : void
      {
         var worldType:String = null;
         var worldHasMoreThanOneSeason:Boolean = false;
         if(result)
         {
            if(result.success)
            {
               worldType = Global.worldManager.currentWorldType;
               worldHasMoreThanOneSeason = WorldSeasonsManager.getInstance().getNumSeasonsForWorld(worldType) > 1 ? true : false;
               if(worldHasMoreThanOneSeason)
               {
                  this.setWitherStatusSecondSeason(result.witherOn);
               }
               else
               {
                  Global.setCurrentWitherStatus(result.witherOn);
                  this.setFullGrownItems(result.witherOn);
               }
            }
         }
      }
      
      private function setFullGrownItems(witherOn:Boolean, terrainCode:int = 0) : void
      {
         var items:Array = null;
         var item:WorldObject = null;
         var itemIdx:int = 0;
         var witherState:Boolean = false;
         var withered:Boolean = false;
         var isGrown:Boolean = false;
         var terrainPlacedOn:Array = null;
         if(!witherOn)
         {
            items = Global.world.getObjects();
            for(itemIdx = 0; itemIdx < items.length; itemIdx++)
            {
               item = items[itemIdx] as WorldObject;
               witherState = item.hasOwnProperty("isWitheredState") && Boolean(item["isWitheredState"]());
               withered = item.hasOwnProperty("isWithered") && Boolean(item["isWithered"]());
               isGrown = item.hasOwnProperty("isGrown") && Boolean(item["isGrown"]());
               if((witherState || withered || isGrown) && item.hasOwnProperty("setFullGrown"))
               {
                  if(terrainCode > 0)
                  {
                     terrainPlacedOn = TerrainUtil.getTerrainCodesForItemInstance(item as ItemInstance);
                     if(terrainPlacedOn.indexOf(terrainCode) >= 0)
                     {
                        item["setFullGrown"]();
                     }
                  }
                  else
                  {
                     item["setFullGrown"]();
                  }
               }
            }
         }
      }
      
      private function setWitherStatusSecondSeason(witherOn:Boolean) : void
      {
         var currentTerrainCode:int = 0;
         var terrainCodes:Array = this.m_item.getTerrainSetCodes();
         for each(currentTerrainCode in terrainCodes)
         {
            Global.setCurrentWitherStatusArray(currentTerrainCode,witherOn);
            this.setFullGrownItems(witherOn,currentTerrainCode);
         }
      }
   }
}

