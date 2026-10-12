package Classes.FeatureComponents
{
   import Classes.Constants.ZLocConstants;
   import Classes.FeatureBuilding;
   import Classes.ZItem.BuildingItem;
   import Classes.util.ZLocUtils;
   import DataSources.BaseDataSource;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Events.GenericPopupEvent;
   import Managers.FarmGameSettingsManager;
   import Transactions.TInstantGrowFeatureBuilding;
   
   public class InstantGrowFManager extends FeatureManager
   {
      
      private var m_pricingTable:Object;
      
      public function InstantGrowFManager(owner:FeatureBuilding)
      {
         super(owner);
      }
      
      public function canInstantGrow() : Boolean
      {
         var result:Boolean = false;
         if(m_owner.isHarvestEnabled() && !m_owner.isHarvestable())
         {
            result = true;
         }
         return result;
      }
      
      public function promptForInstantGrow(callback:Function = null) : void
      {
         var cost:int = this.getInstantGrowCost();
         var message:String = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,(m_owner.getFarmItem() as BuildingItem).buildingName + "_instagrow_confirmation",{"count":cost});
         UI.displayMessage(message,GenericPopup.TYPE_ACCEPTCANCEL,this.generateOnClosePromt(callback),"",true);
      }
      
      private function generateOnClosePromt(callback:Function = null) : Function
      {
         return function(event:GenericPopupEvent):void
         {
            var result:* = false;
            if(event.button == GenericPopup.ACCEPT)
            {
               result = performInstantGrow();
            }
            if(callback != null)
            {
               callback(result);
            }
         };
      }
      
      public function getInstantGrowCost() : int
      {
         var result:int = 0;
         var featureData:BaseDataSource = null;
         var levelsDataArray:Array = null;
         var levelData:BaseDataSource = null;
         var featuresXML:XMLList = null;
         var featureXML:XMLList = null;
         var levels:XMLList = null;
         var levelCount:int = 0;
         var levelXML:XML = null;
         var i:int = 0;
         if(this.m_pricingTable == null)
         {
            this.m_pricingTable = {};
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               featureData = owner.getFarmItem().getFeatureDataByName(FeatureManager.INSTANT_GROWN_FEATURE_NAME);
               if(featureData)
               {
                  if(featureData.hasProperty("levelPricing"))
                  {
                     levelsDataArray = featureData.getArray("levelPricing","level");
                     if(levelsDataArray.length > 0)
                     {
                        for each(levelData in levelsDataArray)
                        {
                           if(levelData.hasProperty("num") && levelData.hasProperty("cost"))
                           {
                              this.m_pricingTable[levelData.getInt("num")] = levelData.getInt("cost");
                           }
                        }
                     }
                  }
               }
            }
            else
            {
               featuresXML = owner.getFarmItem().getFeaturesXML();
               featureXML = featuresXML.(@name == FeatureManager.INSTANT_GROWN_FEATURE_NAME);
               if(featureXML != null)
               {
                  if(featureXML.hasOwnProperty("levelPricing"))
                  {
                     levels = featureXML.levelPricing.level;
                     levelCount = levels.length();
                     for(i = 0; i < levelCount; i++)
                     {
                        levelXML = levels[i];
                        if(levelXML.hasOwnProperty("@num") && levelXML.hasOwnProperty("@cost"))
                        {
                           this.m_pricingTable[levelXML.@num] = levelXML.@cost;
                        }
                     }
                  }
               }
            }
         }
         if(Boolean(this.m_pricingTable) && Boolean(this.m_pricingTable[m_owner.storageLevel]))
         {
            result = int(this.m_pricingTable[m_owner.storageLevel]);
         }
         return result;
      }
      
      private function performInstantGrow() : Boolean
      {
         var result:Boolean = false;
         var cost:int = this.getInstantGrowCost();
         if(Global.player.canBuyCash(cost))
         {
            Global.player.cash -= cost;
            TransactionManager.addTransaction(new TInstantGrowFeatureBuilding(m_owner));
            m_owner.setFullGrown();
            result = true;
         }
         return result;
      }
   }
}

