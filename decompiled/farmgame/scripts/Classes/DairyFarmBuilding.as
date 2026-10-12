package Classes
{
   import Classes.Constants.CollectionsConstants;
   import Classes.Constants.Experiments;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.DairyFarmWithdrawal;
   import Display.GenericIconPopup;
   import Display.GenericPopup;
   import Display.GiftMission;
   import Display.UI;
   import Engine.Helpers.Vector3;
   import Engine.Managers.TransactionManager;
   import Events.GenericPopupEvent;
   import Managers.CollectionsManager;
   import Managers.FarmStatsManager;
   import Transactions.TDeprecateItem;
   import Widgets.Windows.ArrowIndicatorWindow;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   
   public class DairyFarmBuilding extends AnimalStorageBuilding
   {
      
      public static const DAIRY_FARM_COUNTER:String = "dairyfarm";
      
      private static const DAIRYFARM_ARROW_FREQUENCY_KEY:String = "dairyFarmArrowFreqKey";
      
      private static const ARROW_ICON_URL:String = "assets/animals/animal_cow_redbrown_icon.png";
      
      private static const REPLACEMENT_BUILDING_ICON_URL:String = "assets/buildings/bldg_breedingdairy_built_0_icon.png";
      
      private static const REPLACEMENT_BUILDING_NAMES:Array = ["animal_breeding_dairy","animal_breeding_dairy_finished"];
      
      private static const ARROW_DEFAULT_DAYS:int = 7;
      
      private static const REWARD_COW_NAME:String = "cow_redbrown";
      
      private static const REWARD_COWS:int = 1;
      
      private static const REWARD_FEED:int = 5;
      
      protected var m_harvestResult:Object = null;
      
      private var m_showingArrow:Boolean = false;
      
      private var m_deprecating:Boolean = false;
      
      private var m_shouldCheckArrow:Boolean = false;
      
      private var m_lastClickedTimeStamp:Number = 0;
      
      public function DairyFarmBuilding(buildingType:String = null)
      {
         super(buildingType);
      }
      
      override public function onHarvestComplete(result:Object) : void
      {
         var mission:GiftMission = null;
         this.m_harvestResult = result;
         if(result.animalType)
         {
            mission = new GiftMission(GiftMission.STATUS_FIND_HOME,result.animalType,result.lonelyAnimalId);
            mission.setTrackerKey("lonely_cow-" + result.animalType);
            UI.displayPopup(mission,true,"lonelyCowPopup",true);
         }
         FarmStatsManager.count(DAIRY_FARM_COUNTER,"harvest");
      }
      
      override public function addItem(resource:MapResource, fromStorage:int = 0, isGift:Boolean = false, sendStoreItem:Boolean = true, force:Boolean = false) : Boolean
      {
         var animal:Animal = resource as Animal;
         var success:Boolean = super.addItem(resource,fromStorage,isGift,sendStoreItem,force);
         if(animal.getItem().name == "bull")
         {
            this.showBullDiaryFarmPopup();
            FarmStatsManager.count(DAIRY_FARM_COUNTER,"store_bull");
         }
         FarmStatsManager.count("Market","actionMenu","Store_cow");
         return success;
      }
      
      protected function showBullDiaryFarmPopup() : void
      {
         var seenDairyFarmBullPopup:String = "DairyFarmBullPopup";
         if(!Global.player.getSeenFlag(seenDairyFarmBullPopup))
         {
            UI.displayPopup(new GenericPopup(ZLocUtils.t("Dialogs","DairyFarmBullTip"),GenericPopup.TYPE_OK),true,"dairyFarmBullPopup",true);
            Global.player.setSeenFlag(seenDairyFarmBullPopup);
         }
      }
      
      override public function displayStorageDialog(defaultAction:String = "") : void
      {
         UI.displayStorageDialog(new DairyFarmWithdrawal(this));
      }
      
      override protected function updatePlantTimeOnStore(itemCount:int, resource:MapResource) : void
      {
         if(resource is HarvestableResource)
         {
            plantTime = (resource as HarvestableResource).plantTime;
            setState(STATE_BARE);
         }
      }
      
      override public function harvest(energySource:int = 0, energy:Number = 0, showNoEnergyMessage:Boolean = true, updateBackend:Boolean = true, neighborId:String = "0") : Boolean
      {
         var position:Vector3 = null;
         var itemCode:String = null;
         var itemNumber:int = 0;
         var itemName:String = null;
         var i:int = 0;
         var farmObject:FarmGameObject = null;
         var success:Boolean = false;
         if(!this.m_deprecating)
         {
            position = this.getPosition();
            for(itemCode in m_contents)
            {
               itemNumber = int(m_contents[itemCode]);
               itemName = Global.farmGameSettingsManager.getFarmItemNameByCode(itemCode);
               for(i = 0; i < itemNumber; i++)
               {
                  farmObject = new FarmGameObject();
                  CollectionsManager.getInstance().executeCollectionAction(CollectionsConstants.ACTION_HARVEST_TREE,new HarvestableResource(itemName),position);
               }
            }
            success = super.harvest(energySource,energy,showNoEnergyMessage,updateBackend,neighborId);
         }
         return success;
      }
      
      override public function onUpdate(delta:Number) : void
      {
         super.onUpdate(delta);
         if(this.m_shouldCheckArrow)
         {
            this.checkShowArrow();
         }
      }
      
      override protected function replaceContent(newContent:DisplayObject, shouldRedrawMask:Boolean = false) : void
      {
         super.replaceContent(newContent,shouldRedrawMask);
         this.checkShowArrow();
         this.m_shouldCheckArrow = true;
      }
      
      private function checkShowArrow() : void
      {
         var shouldShowArrow:Boolean = false;
         if(this.notifyDeprecationExperimentUnlocked() && !Global.worldManager.isVisiting())
         {
            this.m_lastClickedTimeStamp = Global.player.getFeatureLastShown(DAIRYFARM_ARROW_FREQUENCY_KEY);
            shouldShowArrow = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND - this.m_lastClickedTimeStamp >= FarmGameUtil.NUM_SECS_IN_DAY * Global.farmGameSettingsManager.getInt("dairyFarmTradeInArrowFrequencyDays",ARROW_DEFAULT_DAYS);
            if(shouldShowArrow && !this.m_showingArrow)
            {
               this.generateArrowIndicator();
            }
            else if(!shouldShowArrow && this.m_showingArrow)
            {
               this.hideArrowDisplay();
            }
         }
      }
      
      private function generateArrowIndicator() : void
      {
         var sprite:Sprite = null;
         var iconPath:String = null;
         var title:String = null;
         var text:String = null;
         sprite = m_displayObject as Sprite;
         if(m_arrow == null && sprite.numChildren > 0)
         {
            this.m_hideArrow = false;
            iconPath = Global.getAssetURL(ARROW_ICON_URL);
            title = ZLocUtils.t("Dialogs","DairyFarm_Arrow_Title");
            text = ZLocUtils.t("Dialogs","DairyFarm_Arrow_Text");
            m_arrow = new ArrowIndicatorWindow(iconPath,title,text);
            if(m_arrow != null)
            {
               m_arrow.visible = true;
               this.m_showingArrow = true;
               sprite.addChild(m_arrow);
               this.setArrowPosition();
            }
         }
      }
      
      private function notifyDeprecationExperimentUnlocked() : Boolean
      {
         return Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_DAIRYFARM_NOTIFY_DEPRECATION) > 0;
      }
      
      override public function hideArrowDisplay() : void
      {
         if(Boolean(m_arrow) && Boolean(this.m_showingArrow) && m_arrow.parent != null)
         {
            m_arrow.visible = false;
            this.m_showingArrow = false;
            m_arrow.parent.removeChild(m_arrow);
            m_arrow = null;
            conditionallyRedraw(true);
         }
      }
      
      override public function onMouseOver(event:MouseEvent) : void
      {
         super.onMouseOver(event);
         this.updateArrowIndicator();
      }
      
      override public function onMouseOut() : void
      {
         super.onMouseOut();
         this.updateArrowIndicator();
      }
      
      override public function onClick() : void
      {
         var multiplier:int = 0;
         var buildings:Array = null;
         var building:DairyFarmBuilding = null;
         var farmItem:FarmItem = null;
         var body:String = null;
         var iconPath:String = null;
         var tmpPopup:GenericPopup = null;
         if(this.notifyDeprecationExperimentUnlocked() && (this.m_showingArrow || this.m_deprecating))
         {
            if(this.m_showingArrow && !this.m_deprecating)
            {
               FarmStatsManager.count(DAIRY_FARM_COUNTER,"deprecation","arrow_clicked");
               this.hideArrowDisplay();
               multiplier = 0;
               buildings = Global.world.getObjectsByClass(DairyFarmBuilding);
               for each(building in buildings)
               {
                  multiplier += building.getExpansionLevel();
               }
               farmItem = Global.farmGameSettingsManager.getFarmItemByName(REWARD_COW_NAME);
               body = ZLocUtils.t("Dialogs","DairyFarm_Tradein",{
                  "count1":REWARD_COWS * multiplier,
                  "cowName":ZLocUtils.tk_pk(farmItem.friendlyName,"",multiplier),
                  "count2":REWARD_FEED * multiplier
               });
               iconPath = Global.getAssetURL(ARROW_ICON_URL);
               tmpPopup = new GenericPopup(body,GenericPopup.TYPE_ACCEPTCANCEL,this.onTradeinDialogClosed,GenericPopup.GENERIC_ASSET_MED);
               UI.displayPopup(tmpPopup,false,"DairyFarm_Tradein",true);
            }
         }
         else
         {
            super.onClick();
         }
      }
      
      public function getExpansionLevel() : int
      {
         return capacity / 10 - 1;
      }
      
      public function onTradeinDialogClosed(event:GenericPopupEvent) : void
      {
         var buildings:Array = null;
         var building:DairyFarmBuilding = null;
         var localizedText:String = null;
         var iconPath:String = null;
         var message:GenericIconPopup = null;
         if(event.button == GenericPopup.ACCEPT)
         {
            FarmStatsManager.count(DAIRY_FARM_COUNTER,"deprecation","tradein_accept");
            buildings = Global.world.getObjectsByClass(DairyFarmBuilding);
            for each(building in buildings)
            {
               building.startDeprecation();
            }
            localizedText = ZLocUtils.t("Dialogs","DairyFarm_DeprecationComplete");
            iconPath = Global.getAssetURL(REPLACEMENT_BUILDING_ICON_URL);
            message = new GenericIconPopup(localizedText,GenericPopup.TYPE_OK,this.onBuyFromMarket,iconPath,false,false);
            message.setAcceptTextName("Market");
            UI.displayPopup(message,true);
         }
         else
         {
            this.m_lastClickedTimeStamp = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
            Global.player.setFeatureLastShown(DAIRYFARM_ARROW_FREQUENCY_KEY,this.m_lastClickedTimeStamp,true);
            FarmStatsManager.count(DAIRY_FARM_COUNTER,"deprecation","tradein_cancel");
         }
      }
      
      private function onBuyFromMarket(event:GenericPopupEvent) : void
      {
         UI.displayMiniMarketDialog(REPLACEMENT_BUILDING_NAMES,UI.MARKET_CONTEXT_UNKNOWN,"building",null,true);
      }
      
      public function startDeprecation() : void
      {
         this.m_deprecating = true;
         TransactionManager.addTransaction(new TDeprecateItem(this));
         FarmStatsManager.count(DAIRY_FARM_COUNTER,"deprecation","deprecate",m_itemName);
      }
      
      private function updateArrowIndicator() : void
      {
         var arrowIndicatorWindow:ArrowIndicatorWindow = null;
         if(Boolean(Global.selectedAvatar) && this.notifyDeprecationExperimentUnlocked())
         {
            arrowIndicatorWindow = m_arrow as ArrowIndicatorWindow;
            if(arrowIndicatorWindow)
            {
               arrowIndicatorWindow.showRolloverText(isHighlighted());
            }
         }
      }
      
      override protected function setArrowPosition() : void
      {
         var point:Point = null;
         var spr:Sprite = null;
         if(Boolean(m_arrow) && Boolean(m_displayObject))
         {
            point = new Point();
            spr = m_displayObject as Sprite;
            m_arrow.scaleX = ARROW_SCALE / m_displayObject.scaleX;
            m_arrow.scaleY = ARROW_SCALE / m_displayObject.scaleY;
            if(spr.getChildAt(0))
            {
               point.y = -1 * Math.min(m_arrow.height,DEFAULT_ARROW_SIZE_Y);
               point.x = (spr.getChildAt(0).width - Math.min(m_arrow.width,DEFAULT_ARROW_SIZE_X) * spr.scaleX) / 2;
               m_arrow.y = point.y - 100;
               m_arrow.x = point.x - 30;
            }
         }
      }
   }
}

