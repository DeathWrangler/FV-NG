package Classes.consumables
{
   import Classes.Animal;
   import Classes.Constants.ToasterIconPaths;
   import Classes.SimpleHarvestableResource;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Managers.FarmGameSettingsManager;
   import Managers.FeatureBuildingSurfacingManager;
   import Managers.ToasterManager;
   import Widgets.Windows.TwoIconTitleToasterWindow;
   import flash.geom.Point;
   
   public class CHarvestAnimals extends CHarvestAllOfType
   {
      
      private var m_harvestType:String;
      
      private var m_harvestObjectIds:Array;
      
      private var m_hasHarvestType:Boolean = false;
      
      public function CHarvestAnimals(itemName:String)
      {
         super(itemName);
      }
      
      override public function onFailedPerform() : void
      {
         var titleMsg:String = ZLocUtils.t("Dialogs","Consumable_Use_Fail_Title");
         var msg:String = ZLocUtils.t("Dialogs","Consumable_Harvest_Animals_Fail");
         ToasterManager.getInstance().add(new TwoIconTitleToasterWindow(titleMsg,msg,ToasterIconPaths.FARMHAND_ICON,"",ToasterIconPaths.DIALOG_ASSET,0.6,0.7,new Point(8,8),new Point(15,0),null));
      }
      
      override protected function getHarvestables() : Array
      {
         var harvestType:String = null;
         var harvestCount:Number = NaN;
         var allObjects:Array = null;
         var totalObjects:Number = NaN;
         var forceUpdate:Boolean = false;
         var hasHarvestObjectSource:Boolean = false;
         var ignorePetHarvest:String = null;
         var itemName:String = null;
         var curItem:FarmItem = null;
         var harvestObject:SimpleHarvestableResource = null;
         var harvestables:Array = Global.world.getObjectsByClass(Animal);
         var isInDataSourceExperiment:Boolean = FarmGameSettingsManager.isInDataSourceExperiment();
         if(isInDataSourceExperiment)
         {
            harvestType = getItem().getStringFromDataSource("harvestType");
            harvestCount = getItem().getNumberFromDataSource("harvestCount");
         }
         else
         {
            harvestType = getItem().xml.harvestType;
            harvestCount = Number(getItem().xml.harvestCount);
         }
         if(harvestType != null)
         {
            this.m_hasHarvestType = true;
            this.m_harvestType = harvestType;
            allObjects = harvestables;
            harvestables = [];
            this.m_harvestObjectIds = [];
            totalObjects = 0;
            forceUpdate = Global.experimentManager.getExperimentVariant("fv_updateGrowForFarmhands") > 0;
            hasHarvestObjectSource = false;
            for each(harvestObject in allObjects)
            {
               curItem = harvestObject.getItem();
               if(isInDataSourceExperiment)
               {
                  hasHarvestObjectSource = curItem != null;
                  if(hasHarvestObjectSource)
                  {
                     ignorePetHarvest = curItem.getStringFromDataSource("ignorePetHarvest");
                     itemName = curItem.getStringFromDataSource("name");
                  }
               }
               else
               {
                  hasHarvestObjectSource = Boolean(curItem) && Boolean(curItem.xml);
                  if(hasHarvestObjectSource)
                  {
                     ignorePetHarvest = curItem.xml.@ignorePetHarvest.toString();
                     itemName = curItem.xml.@name;
                  }
               }
               if(hasHarvestObjectSource)
               {
                  if(forceUpdate)
                  {
                     harvestObject.updateGrowPercentage();
                  }
                  if(harvestObject.isHarvestable())
                  {
                     if(harvestCount > 0)
                     {
                        if(ignorePetHarvest == "" || ignorePetHarvest == "false")
                        {
                           harvestables.push(harvestObject);
                           this.m_harvestObjectIds.push(harvestObject.getId());
                           if(totalObjects++ >= harvestCount - 1)
                           {
                              break;
                           }
                        }
                     }
                     else if(itemName.indexOf(harvestType,0) == 0)
                     {
                        if(ignorePetHarvest == "" || ignorePetHarvest == "false")
                        {
                           harvestables.push(harvestObject);
                        }
                     }
                  }
               }
            }
         }
         FeatureBuildingSurfacingManager.getInstance().sortMapResourcesByFeatureBuildingRank(harvestables,FeatureBuildingSurfacingManager.ANIMAL_SURFACING_KEYWORD);
         return harvestables;
      }
      
      override protected function displayHarvestResults(totalCoinYield:uint, totalMasteryYield:int = 0) : void
      {
         var msg:String = null;
         var titleMsg:String = null;
         var iconURL:String = null;
         if(this.m_hasHarvestType && this.m_harvestType.length > 0 && this.m_harvestType != "")
         {
            titleMsg = ZLocUtils.t("Dialogs","Consumable_Use_Title",{
               "quantity":totalCoinYield,
               "coinQuantity":totalCoinYield
            });
            msg = ZLocUtils.t("Dialogs","Consumable_Harvest_" + this.m_harvestType + "_Use",{
               "quantity":totalCoinYield,
               "coinQuantity":totalCoinYield
            });
            if(this.m_harvestType == "first20")
            {
               iconURL = ToasterIconPaths.BORDERCOLLIE_ICON;
            }
            else if(this.m_harvestType == "cow")
            {
               iconURL = ToasterIconPaths.AUSTRALIANCOW_ICON;
            }
            else if(this.m_harvestType == "sheep")
            {
               iconURL = ToasterIconPaths.SHEEP_ICON;
            }
            else if(this.m_harvestType == "duck")
            {
               iconURL = ToasterIconPaths.DUCK_ICON;
            }
            else
            {
               iconURL = ToasterIconPaths.FARMHAND_ICON;
            }
            ToasterManager.getInstance().add(new TwoIconTitleToasterWindow(titleMsg,msg,ToasterIconPaths.CONSUMECOIN_ICON,iconURL,ToasterIconPaths.DIALOG_ASSET,0.6,0.7,new Point(8,8),null,null));
         }
         else
         {
            titleMsg = ZLocUtils.t("Dialogs","Consumable_Use_Title",{"coinQuantity":totalCoinYield});
            msg = ZLocUtils.t("Dialogs","Consumable_Harvest_Animals_Use",{"coinQuantity":totalCoinYield});
            ToasterManager.getInstance().add(new TwoIconTitleToasterWindow(titleMsg,msg,ToasterIconPaths.CONSUMECOIN_ICON,ToasterIconPaths.FARMHAND_ICON,ToasterIconPaths.DIALOG_ASSET,0.5,0.5,new Point(15,8),new Point(15,0),null));
         }
      }
      
      override protected function canHarvest(harvestableResource:SimpleHarvestableResource) : Boolean
      {
         var animal:Animal = harvestableResource as Animal;
         var success:Boolean = false;
         if(animal.isHarvestable() && !animal.hasTransformAction())
         {
            success = true;
         }
         return success;
      }
      
      public function getHarvestObjectIds() : Array
      {
         return this.m_harvestObjectIds;
      }
      
      override public function setTargetsBusy() : Array
      {
         var harvestable:SimpleHarvestableResource = null;
         var harvestableItems:Array = this.getHarvestables();
         var itemsSetToBusy:Array = new Array();
         for each(harvestable in harvestableItems)
         {
            if(this.canHarvest(harvestable))
            {
               harvestable.isBusy = true;
               itemsSetToBusy.push(harvestable);
            }
         }
         return itemsSetToBusy;
      }
   }
}

