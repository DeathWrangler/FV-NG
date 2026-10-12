package Classes.consumables
{
   import Classes.Constants.ToasterIconPaths;
   import Classes.FeatureBuilding;
   import Classes.SimpleHarvestableResource;
   import Classes.ZItem.FarmItem;
   import Classes.instagrow.InstagrowUtils;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Managers.StatsManager;
   import Events.GenericPopupEvent;
   import Managers.FarmGameSettingsManager;
   import Managers.ToasterManager;
   import Widgets.Windows.TwoIconTitleToasterWindow;
   import flash.geom.Point;
   
   public class CHarvestBlooms extends CHarvestAllOfType
   {
      
      public function CHarvestBlooms(itemName:String)
      {
         super(itemName);
      }
      
      override public function onFailedPerform() : void
      {
         var msg:String = ZLocUtils.t("Dialogs","Consumable_Harvest_Blooms_Fail");
         UI.displayPopup(new GenericPopup(msg,GenericPopup.TYPE_YESNO,this.failedPerformCallback));
      }
      
      private function failedPerformCallback(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.YES)
         {
            StatsManager.count("bloom","harvestAll","failed","AcceptInstantGrow");
            InstagrowUtils.tryShowInstagrowWindow("FailCHarvestBlooms");
         }
         else
         {
            StatsManager.count("bloom","harvestAll","failed","DenyInstantGrow");
         }
      }
      
      override protected function getHarvestables() : Array
      {
         var harvestBuilding:FeatureBuilding = null;
         var buildingItem:FarmItem = null;
         var buildingName:String = null;
         var item:XML = null;
         var itemType:String = null;
         var itemName:String = null;
         var result:Array = new Array();
         var buildings:Array = Global.world.getObjectsByClass(FeatureBuilding);
         var blackListVar:String = Global.flashHotParams["FARMWORKER_BLACKLIST"] as String;
         var blackList:Array = blackListVar.split(",");
         for each(harvestBuilding in buildings)
         {
            if(Boolean(harvestBuilding) && Boolean(harvestBuilding.getItem()))
            {
               if(FarmGameSettingsManager.isInDataSourceExperiment())
               {
                  buildingItem = harvestBuilding.getItem();
                  if(buildingItem.getStringFromDataSource("type") == "bloom")
                  {
                     buildingName = buildingItem.getStringFromDataSource("name");
                     if(Boolean(buildingName) && blackList.indexOf(buildingName) == -1)
                     {
                        result.push(harvestBuilding);
                     }
                  }
               }
               else
               {
                  item = harvestBuilding.getItem().xml;
                  if(item.attribute("type"))
                  {
                     itemType = item.attribute("type").toString();
                     if(itemType == "bloom")
                     {
                        if(item.attribute("name"))
                        {
                           itemName = item.attribute("name").toString();
                           if(blackList.indexOf(itemName) == -1)
                           {
                              result.push(harvestBuilding);
                           }
                        }
                     }
                  }
               }
            }
         }
         return result;
      }
      
      override protected function displayHarvestResults(totalCoinYield:uint, totalMasteryYield:int = 0) : void
      {
         var msg:String = null;
         var titleMsg:String = ZLocUtils.t("Dialogs","Consumable_Use_Title",{"coinQuantity":totalCoinYield});
         if(totalMasteryYield)
         {
            msg = ZLocUtils.t("Dialogs","Consumable_Harvest_Blooms_Use_Mastery",{
               "coinQuantity":totalCoinYield,
               "quantity":totalMasteryYield
            });
         }
         else
         {
            msg = ZLocUtils.t("Dialogs","Consumable_Harvest_Blooms_Use",{"coinQuantity":totalCoinYield});
         }
         ToasterManager.getInstance().add(new TwoIconTitleToasterWindow(titleMsg,msg,ToasterIconPaths.CONSUMECOIN_ICON,ToasterIconPaths.GARDENER_ICON,ToasterIconPaths.DIALOG_ASSET,0.6,0.7,new Point(8,8),new Point(15,0),null));
      }
      
      override protected function canHarvest(harvestableResource:SimpleHarvestableResource) : Boolean
      {
         return harvestableResource.isHarvestable();
      }
   }
}

