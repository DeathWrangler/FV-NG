package Transactions
{
   import Classes.Constants.Experiments;
   import Classes.NeighborActions.NeighborActionConstants;
   import Classes.VisitorManager;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import Managers.WorldManager;
   import flash.events.Event;
   
   public class TLoadNeighbor extends TBaseWorldLoad
   {
      
      public static const METHOD_LOAD_NEIGHBOR_WORLD:String = "loadNeighborWorld";
      
      private var m_neighborId:String;
      
      public function TLoadNeighbor(neighborId:String, manager:WorldManager)
      {
         super(manager);
         this.m_neighborId = neighborId;
      }
      
      override public function perform() : void
      {
         signedCall("WorldService." + METHOD_LOAD_NEIGHBOR_WORLD,this.m_neighborId);
      }
      
      override public function getTransactionData() : Object
      {
         var result:Object = new Object();
         result.method = METHOD_LOAD_NEIGHBOR_WORLD;
         result.neighborId = this.m_neighborId;
         return result;
      }
      
      override protected function onComplete(result:Object) : void
      {
         if(Boolean(result) && Boolean(result.hasOwnProperty("isNeighborMissing")) && result.isNeighborMissing === true)
         {
            Global.worldManager.setStateOnFailedNeighborVisit();
            UI.displayMessage(ZLocUtils.t("Dialogs","NeighborLoad_Failed"),GenericPopup.TYPE_OK,null,"",true);
         }
         else
         {
            if(result.neighborCraftingCrew)
            {
               this.parseCraftingCrewForClient(result.neighborCraftingCrew);
            }
            VisitorManager.getInstance().loadUGCItemData(result.user["ugcItemData"]);
            VisitorManager.getInstance().loadInstnaceDataStore(result.user["instanceDataStore"]);
            super.onComplete(result);
         }
      }
      
      override protected function onAssetLoadComplete(event:Event) : void
      {
         super.onAssetLoadComplete(event);
         if(Global.worldManager.isVisitingNeighbor() && Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_NEIGHBOR_VISIT_PURCHASE) > 0 && !VisitorManager.getInstance().hasActionTypeLeft(NeighborActionConstants.LIMIT_TYPE_FARM_ACTION))
         {
            Global.world.attachTagsToItems(Global.farmGameSettingsManager.getString("neighborLEItemTagUrl"),function(item:FarmItem):Boolean
            {
               return item.isLimitedItem() && item.buyableFromNeighbor;
            },true);
         }
      }
      
      private function parseCraftingCrewForClient(crewData:Object) : void
      {
         var crewIdString:String = null;
         var str1:String = null;
         var str2:String = null;
         var inCrewAlready:Boolean = false;
         for each(crewIdString in crewData)
         {
            str1 = String(crewIdString);
            str2 = String(Global.player.uid);
            if(str1 == str2)
            {
               inCrewAlready = true;
            }
         }
         if(inCrewAlready)
         {
            VisitorManager.getInstance().isVisitedCraftShopCrewMember = true;
         }
         else
         {
            VisitorManager.getInstance().isVisitedCraftShopCrewMember = false;
         }
      }
   }
}

