package Classes
{
   import AvatarMode.AMHarvest;
   import Classes.AreasOfEffect.AOEBonusData;
   import Classes.Avatar.FarmAvatar;
   import Classes.NeighborActions.HarvestNeighborAction;
   import Classes.NeighborActions.NeighborActionConstants;
   import Classes.ZItem.FarmItem;
   import Classes.ZItem.HarvestableItem;
   import Classes.instagrow.InstagrowUtils;
   import Classes.util.ZLocUtils;
   import Display.ContextMenuItem;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Managers.StatsManager;
   import GameMode.GMAirplaneFly;
   import GameMode.GMSnapShot;
   import GameMode.GameMode;
   import Managers.AOEManager;
   import Managers.AvatarRetentionExperimentUtil;
   import Managers.FarmGameSettingsManager;
   import Managers.FarmStatsManager;
   import Transactions.THarvest;
   import Widgets.Constants.Market.Currency;
   import Widgets.Windows.Mastery.MasteryWindow;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   
   public class SimpleHarvestableResource extends HarvestableResource
   {
      
      public static const OBSERVABLE_EVENT_HARVEST:String = "HARVEST";
      
      public static const STATE_BARE:String = "bare";
      
      public static const STATE_RIPE:String = "ripe";
      
      public static const PINK_ARROW:Class = EmbeddedArt.harvestArrowAnimal;
      
      public static const GUITAR_PICK:Class = EmbeddedArt.guitarPick;
      
      public static const BLUE_ARROW:Class = EmbeddedArt.harvestArrowNeighbor;
      
      public static const GOLD_ARROW:Class = EmbeddedArt.bouncing_arrow;
      
      public static const ORANGE_ARROW:Class = EmbeddedArt.harvestArrowOrange;
      
      public static const YELLOW_ARROW:Class = EmbeddedArt.harvestArrowYellow;
      
      protected static const APPLY_GROW:String = "applyInstantGrow";
      
      protected static var m_arrowBitmaps:Object = new Object();
      
      protected static var ARROW_SCALE:Number = 0.5;
      
      protected static var DEFAULT_ARROW_SIZE_X:Number = 40.05;
      
      protected static var DEFAULT_ARROW_SIZE_Y:Number = 50.3;
      
      private static const BASIC_ARROW_BITMAP_KEY:String = "BASIC_ARROW_BITMAP_KEY";
      
      protected static const OPEN_MASTERY:String = "open_mastery";
      
      protected var m_isInHarvestQueue:Boolean = false;
      
      protected var m_arrow:DisplayObject;
      
      protected var m_hideArrow:Boolean = false;
      
      protected var m_arrowArt:Class;
      
      protected var m_bonusMultipliers:Object;
      
      protected var m_bonusCumulative:Object;
      
      protected var m_originalName:String;
      
      public function SimpleHarvestableResource(itemName:String = null)
      {
         this.m_originalName = itemName;
         super(itemName);
         this.m_arrowArt = PINK_ARROW;
         setState(STATE_BARE);
         plantTime = Global.worldTime;
         var useRealItemNameEnabled:Boolean = Boolean(Global.flashHotParams["REALITEMNAME_ENABLED"]);
         if(useRealItemNameEnabled && m_itemName != this.m_originalName)
         {
            if(this.m_originalName.indexOf(FarmItem.ITEM_POSTFIX_SALE) > 0)
            {
               if(FarmGameSettingsManager.isInDataSourceExperiment())
               {
                  m_item.swapToSaleData();
               }
               else
               {
                  m_item.xml = m_item.saleXML;
               }
               StatsManager.count("REALITEMNAME_ENABLED","SimpleHarvestableResource","m_item.xml","m_item.saleXML");
            }
            else if(this.m_originalName.indexOf(FarmItem.ITEM_POSTFIX_CASH) > 0)
            {
               if(FarmGameSettingsManager.isInDataSourceExperiment())
               {
                  m_item.swapToCashData();
               }
               else
               {
                  m_item.xml = m_item.cashXML;
               }
               StatsManager.count("REALITEMNAME_ENABLED","SimpleHarvestableResource","m_item.xml","m_item.cashXML");
            }
         }
      }
      
      override public function getCurrentImageName() : String
      {
         var imageName:String = null;
         switch(state)
         {
            case STATE_BARE:
               imageName = "bare";
               break;
            case STATE_RIPE:
               imageName = "mature";
               break;
            default:
               imageName = super.getCurrentImageName();
         }
         return imageName;
      }
      
      override public function getSaveObject() : Object
      {
         var obj:Object = super.getSaveObject();
         var useRealItemNameEnabled:Boolean = Boolean(Global.flashHotParams["REALITEMNAME_ENABLED"]);
         if(useRealItemNameEnabled && this.m_originalName != null && obj.itemName != null && obj.itemName != this.m_originalName)
         {
            StatsManager.count("REALITEMNAME_ENABLED","SimpleHarvestableResource",obj.itemName,this.m_originalName);
            obj.itemName = this.m_originalName;
         }
         return obj;
      }
      
      override protected function getSellPrice() : int
      {
         return m_item.sellPrice;
      }
      
      public function inQueue() : Boolean
      {
         return this.m_isInHarvestQueue;
      }
      
      override protected function updateToolTipText() : void
      {
         var tooltip:String = null;
         if(isHighlighted())
         {
            if(Global.worldManager.isVisiting() && "" != m_toolTipOverride)
            {
               tooltip = m_toolTipOverride;
            }
            else
            {
               tooltip = this.buildTooltipText();
            }
         }
         else
         {
            tooltip = "";
         }
         setToolTip(tooltip);
         updateToolTipPosition();
      }
      
      protected function buildTooltipText() : String
      {
         return defaultTooltip;
      }
      
      override public function getCursor() : Class
      {
         var cursor:Class = null;
         switch(state)
         {
            case STATE_RIPE:
               if(this.isHarvestable())
               {
                  cursor = EmbeddedArt.cursor_harvest;
               }
         }
         return cursor;
      }
      
      override public function showMenu() : void
      {
         if(this.isMasterable() && !(this.getItem().type == "bloom" && (this as FeatureBuilding).storageLevel == 1))
         {
            m_menuItems.unshift({
               "label":ZLocUtils.t("FarmGame","OpenMastery",{"numMasteryStars":(this.getMasteryFarmItem() as HarvestableItem).masteryStartsString}),
               "action":OPEN_MASTERY
            });
         }
         super.showMenu();
      }
      
      override public function onClick() : void
      {
         var amsState:AMHarvest = null;
         if(Global.worldManager.isVisiting())
         {
            if(Boolean(isHarvestableByNeighbors() && this.state == STATE_RIPE) && Boolean(Global.selectedAvatar) && VisitorManager.getInstance().canPerformAction(this,NeighborActionConstants.LIMIT_TYPE_FARM_ACTION))
            {
               VisitorManager.getInstance().queueActionType(this,NeighborActionConstants.LIMIT_TYPE_FARM_ACTION);
               amsState = Global.selectedAvatar.getStateMachine().getState() as AMHarvest;
               if(Boolean(amsState) && Boolean(amsState.getResource() != this) || !amsState)
               {
                  Global.selectedAvatar.getStateMachine().addState(new AMHarvest(Global.selectedAvatar,this),true);
                  this.m_isInHarvestQueue = true;
               }
            }
            else
            {
               super.onClick();
            }
         }
         else
         {
            onMouseOut();
            this.showMenu();
         }
      }
      
      override public function onMenuClick(event:MouseEvent) : void
      {
         var item:ContextMenuItem = null;
         var clickedApplyGrow:Boolean = false;
         var message:String = null;
         var dialog:GenericPopup = null;
         var asmState:AMHarvest = null;
         if(event.target is ContextMenuItem)
         {
            item = event.target as ContextMenuItem;
            clickedApplyGrow = false;
            switch(item.action)
            {
               case MOVE_OBJECT:
                  this.move();
                  break;
               case SELL_OBJECT:
                  this.sell();
                  break;
               case APPLY_GROW:
                  clickedApplyGrow = true;
                  if(this is IOrchardBuilding)
                  {
                     FarmStatsManager.sample(100,InstagrowUtils.INSTA_GROW_COUNTER,"context_menu_click","orchard",InstagrowUtils.INSTA_GROW_COUNTER,"","User opens context menu from orchard, clicks on instant_grow");
                  }
                  else if(this is AnimalStorageBuilding)
                  {
                     FarmStatsManager.sample(100,InstagrowUtils.INSTA_GROW_COUNTER,"context_menu_click","animal_building",InstagrowUtils.INSTA_GROW_COUNTER,"","User opens context menu from animal_building, clicks on instant_grow");
                  }
                  if(Global.world.addGameMode(new GMAirplaneFly(),true) == false)
                  {
                     message = ZLocUtils.t("Dialogs","InstantGrow_OnlyOnePlaneAtATime");
                     dialog = new GenericPopup(message,GenericPopup.TYPE_OK);
                     UI.displayPopup(dialog);
                  }
                  break;
               case HARVEST_OBJECT:
                  if(this.state == STATE_RIPE && Global.selectedAvatar != null)
                  {
                     asmState = Global.selectedAvatar.getStateMachine().getState() as AMHarvest;
                     if(asmState != null && asmState.getResource() != this || asmState == null)
                     {
                        Global.selectedAvatar.getStateMachine().addState(new AMHarvest(Global.selectedAvatar,this),true);
                        this.m_isInHarvestQueue = true;
                     }
                  }
                  break;
               case OPEN_MASTERY:
                  UI.displayPopup(new MasteryWindow(this.getMasteryWindowType(),this.getMasteryFarmItem()));
                  break;
               default:
                  super.onMenuClick(event);
            }
            if(!clickedApplyGrow)
            {
               if(this is IOrchardBuilding)
               {
                  FarmStatsManager.sample(100,InstagrowUtils.INSTA_GROW_COUNTER,"context_menu_click","orchard","all_other_options","","User opens context menu from orchard, clicks on all_other_options");
               }
               else if(this is AnimalStorageBuilding)
               {
                  FarmStatsManager.sample(100,InstagrowUtils.INSTA_GROW_COUNTER,"context_menu_click","animal_building","all_other_options","","User opens context menu from animal_building, clicks on all_other_options");
               }
            }
         }
      }
      
      protected function getMasteryWindowType() : String
      {
         return MasteryWindow.TYPE_SEED;
      }
      
      override protected function determineState(delta:Number) : void
      {
         if(this.isHarvestable() && state == STATE_BARE)
         {
            setState(STATE_RIPE);
         }
      }
      
      public function getHarvestCurrency() : String
      {
         return Currency.COINS;
      }
      
      override public function isHarvestable() : Boolean
      {
         return getGrowPercentage() == 100 || state == STATE_RIPE;
      }
      
      public function get xpBonusMultiplier() : Number
      {
         return Boolean(this.m_bonusMultipliers) && this.m_bonusMultipliers.hasOwnProperty("xp") ? Number(this.m_bonusMultipliers.xp) : 1;
      }
      
      public function get xpBonusCumulative() : Number
      {
         return Boolean(this.m_bonusCumulative) && this.m_bonusCumulative.hasOwnProperty("xp") ? Number(this.m_bonusCumulative.xp) : 0;
      }
      
      public function get coinBonusMultiplier() : Number
      {
         return Boolean(this.m_bonusMultipliers) && this.m_bonusMultipliers.hasOwnProperty("coin") ? Number(this.m_bonusMultipliers.coin) : 1;
      }
      
      public function get masteryBonusMultiplier() : Number
      {
         return Boolean(this.m_bonusMultipliers) && this.m_bonusMultipliers.hasOwnProperty("mastery") ? Number(this.m_bonusMultipliers.mastery) : 1;
      }
      
      public function get masteryBonusCumulative() : Number
      {
         return Boolean(this.m_bonusCumulative) && this.m_bonusCumulative.hasOwnProperty("mastery") ? Number(this.m_bonusCumulative.mastery) : 0;
      }
      
      override public function doHarvestDropOff(avatar:FarmAvatar, showStatus:Boolean = true) : Object
      {
         var calculatedCoinYield:int = 0;
         var xpYield:int = 0;
         var item:XML = null;
         var coinMultiplier:int = 0;
         var multiplier:int = 0;
         var statusString:String = null;
         var hasItem:Boolean = false;
         var result:Object = new Object();
         var harvestYieldsGroup:HarvestYieldsGroup = new HarvestYieldsGroup();
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            hasItem = true;
            calculatedCoinYield = this.calculateCoinYield(null,m_item);
            xpYield = m_item.getIntFromDataSource("xpYield");
         }
         else
         {
            item = m_item.xml;
            if(item)
            {
               hasItem = true;
               calculatedCoinYield = this.calculateCoinYield(item);
               xpYield = int(item.xpYield);
            }
         }
         if(hasItem)
         {
            result.worldCurrency = this.getHarvestCurrency();
            result.coinYield = Math.round(calculatedCoinYield * this.coinBonusMultiplier);
            result.xpYield = Math.round(xpYield * this.xpBonusMultiplier);
            result.xpYield += this.xpBonusCumulative;
            if(m_item is HarvestableItem)
            {
               multiplier = 1;
               if(Boolean(this.m_bonusMultipliers) && this.m_bonusMultipliers.featureMultiplier > 0)
               {
                  multiplier = int(this.m_bonusMultipliers.featureMultiplier);
               }
               harvestYieldsGroup.applyHarvestYieldsForItem(m_item as HarvestableItem,1,multiplier);
               if((m_item as HarvestableItem).hasMastery)
               {
                  result.hasMastery = true;
                  result.masteryObject = Mastery.createMasteryForItem(m_item);
                  result.masteryYield = Math.round(result.masteryObject.calculateMasteryYield() * this.masteryBonusMultiplier);
               }
            }
            else
            {
               result.hasMastery = false;
            }
            result.xpYield = Global.player.calculateAndAddXp(int(result.xpYield));
            Global.player.updateWorldCurrency(result.worldCurrency,result.coinYield,true);
            coinMultiplier = Global.player.getWorldCurrencyMultiplier(Currency.COINS);
            if(showStatus)
            {
               statusString = harvestYieldsGroup.getDooberStatus();
               if(result.xpYield > 0)
               {
                  if(result.coinYield > 0)
                  {
                     if(canEarnMasteryPoints(result))
                     {
                        statusString += ZLocUtils.t("FarmGame","Status_HarvestCoinsXPMastery",{
                           "coinNum":result.coinYield * coinMultiplier,
                           "xpNum":result.xpYield,
                           "masteryNum":result.masteryYield
                        });
                     }
                     else
                     {
                        statusString += ZLocUtils.t("FarmGame","Status_HarvestCoinsXP",{
                           "coinNum":result.coinYield * coinMultiplier,
                           "xpNum":result.xpYield
                        });
                     }
                  }
                  else if(canEarnMasteryPoints(result))
                  {
                     statusString += ZLocUtils.t("FarmGame","Status_HarvestXPMastery",{
                        "xpNum":result.xpYield,
                        "masteryNum":result.masteryYield
                     });
                  }
                  else
                  {
                     statusString += ZLocUtils.t("FarmGame","Status_HarvestXP",{"xpNum":result.xpYield});
                  }
               }
               else if(result.coinYield > 0)
               {
                  if(canEarnMasteryPoints(result))
                  {
                     statusString += ZLocUtils.t("FarmGame","Status_HarvestPlotMastery",{
                        "coinNum":result.coinYield * coinMultiplier,
                        "masteryNum":result.masteryYield
                     });
                  }
                  else
                  {
                     statusString += ZLocUtils.t("FarmGame","Status_HarvestPlot",{"coinNum":result.coinYield * coinMultiplier});
                  }
               }
               if(AvatarRetentionExperimentUtil.inNoWaitExperiment())
               {
                  this.displayStatus(statusString);
               }
               else
               {
                  avatar.displayStatus(statusString);
               }
            }
         }
         super.doHarvestDropOff(avatar);
         this.m_isInHarvestQueue = false;
         return result;
      }
      
      protected function calculateCoinYield(itemXML:XML, item:FarmItem = null) : int
      {
         var result:int = 0;
         var maxVisitCoins:int = 0;
         if(item)
         {
            result = item.getIntFromDataSource("coinYield");
         }
         else
         {
            result = int(itemXML.coinYield);
         }
         if(Global.worldManager.isVisiting())
         {
            maxVisitCoins = Global.farmGameSettingsManager.getInt("neighborHarvestCoinLimit",50);
            result = Math.min(result,maxVisitCoins);
         }
         return result;
      }
      
      protected function getTHarvestExtraParams() : Object
      {
         return null;
      }
      
      override public function harvest(energySource:int = 0, energy:Number = 0, showNoEnergyMessage:Boolean = true, updateBackend:Boolean = true, neighborId:String = "0") : Boolean
      {
         var aoeResourceIds:Array = null;
         var bonusData:AOEBonusData = null;
         var result:Boolean = false;
         if(this.isHarvestable())
         {
            if(updateBackend || Boolean(Global.flashHotParams["AOE_HARVEST_REMOVE_BYPASS"]))
            {
               aoeResourceIds = getAOESourceIds();
               bonusData = AOEManager.getInstance().computeBonusesForAoeResourceIds(aoeResourceIds,this);
               this.m_bonusMultipliers = bonusData.bonusMultiplierTypes;
               if(this.m_bonusMultipliers)
               {
                  this.m_bonusMultipliers.harvestYieldMultiplier = 1;
               }
               this.m_bonusCumulative = bonusData.bonusCumulativeTypes;
               if(aoeResourceIds != null)
               {
                  FarmStatsManager.count(AOEManager.STATS_COUNTER_NAME,"area_harvest_" + m_itemName,bonusData.numSources.toString(),this.masteryBonusMultiplier.toString(),this.coinBonusMultiplier.toString());
               }
            }
            if(updateBackend)
            {
               if(Global.worldManager.isVisiting())
               {
                  if(isHarvestableByNeighbors())
                  {
                     VisitorManager.getInstance().doAction(new HarvestNeighborAction(this));
                  }
               }
               else
               {
                  addTransaction(new THarvest(this,energySource,energy,null,neighborId,this.getTHarvestExtraParams(),aoeResourceIds));
               }
            }
            setState(STATE_BARE);
            plantTime = Global.worldTime;
            m_observer.notifyObservers(OBSERVABLE_EVENT_HARVEST,this);
            result = true;
         }
         return result;
      }
      
      override protected function replaceContent(newContent:DisplayObject, shouldRedrawMask:Boolean = false) : void
      {
         super.replaceContent(newContent,shouldRedrawMask);
         if(Boolean(this.m_arrow) && !this.m_hideArrow)
         {
            (m_displayObject as Sprite).addChild(this.m_arrow);
            this.setArrowPosition();
         }
      }
      
      protected function generateHarvestArrow() : DisplayObject
      {
         var arrow:DisplayObject = this.createHarvestArrow();
         this.setArrowBitmapsData(arrow);
         return arrow;
      }
      
      protected function setArrowBitmapsData(arrow:DisplayObject) : void
      {
         if(m_arrowBitmaps[BASIC_ARROW_BITMAP_KEY] == null)
         {
            m_arrowBitmaps[BASIC_ARROW_BITMAP_KEY] = new BitmapData(arrow.width,arrow.height,true,0);
            m_arrowBitmaps[BASIC_ARROW_BITMAP_KEY].draw(arrow);
         }
      }
      
      protected function createHarvestArrow() : DisplayObject
      {
         return new this.m_arrowArt();
      }
      
      override public function isPixelInside(pixel:Point) : Boolean
      {
         var result:Boolean = false;
         if(HarvestableResource.IS_HARVESTING == m_actionState)
         {
            result = false;
         }
         else
         {
            result = Boolean(super.isPixelInside(pixel)) || this.isPixelInsideArrow(pixel);
         }
         return result;
      }
      
      protected function isPixelInsideArrow(pixel:Point) : Boolean
      {
         var localPixel:Point = null;
         var result:Boolean = false;
         if(Boolean(this.m_arrow && m_displayObject) && Boolean(this.getArrowBitmapData()) && Boolean(pixel))
         {
            localPixel = pixel.subtract(new Point(m_displayObject.x,m_displayObject.y));
            localPixel.x = (localPixel.x - this.m_arrow.x * m_displayObject.scaleX) / this.m_arrow.scaleX / m_displayObject.scaleX;
            localPixel.y = (localPixel.y - this.m_arrow.y * m_displayObject.scaleY) / this.m_arrow.scaleY / m_displayObject.scaleY;
            result = this.getArrowBitmapData().hitTest(new Point(0,0),128,localPixel);
         }
         return result;
      }
      
      protected function getArrowBitmapData() : BitmapData
      {
         return m_arrowBitmaps[BASIC_ARROW_BITMAP_KEY];
      }
      
      protected function setArrowPosition() : void
      {
         var point:Point = null;
         var spr:Sprite = null;
         if(Boolean(this.m_arrow) && Boolean(m_displayObject))
         {
            point = new Point();
            spr = m_displayObject as Sprite;
            this.m_arrow.scaleX = ARROW_SCALE / m_displayObject.scaleX;
            this.m_arrow.scaleY = ARROW_SCALE / m_displayObject.scaleY;
            if(spr.getChildAt(0))
            {
               point.y = -1 * Math.min(this.m_arrow.height,DEFAULT_ARROW_SIZE_Y);
               point.x = (spr.getChildAt(0).width - Math.min(this.m_arrow.width,DEFAULT_ARROW_SIZE_X) * spr.scaleX) / 2;
               if(point.x != this.m_arrow.x || point.y != this.m_arrow.y)
               {
                  this.m_arrow.y = point.y;
                  this.m_arrow.x = point.x;
               }
            }
         }
      }
      
      public function hideArrowDisplay() : void
      {
         if(Boolean(this.m_arrow) && Boolean(this.m_arrow.visible) && this.m_arrow.parent != null)
         {
            this.m_arrow.visible = false;
            this.m_hideArrow = true;
            this.m_arrow.parent.removeChild(this.m_arrow);
            this.m_arrow = null;
            m_arrowBitmaps[BASIC_ARROW_BITMAP_KEY] = null;
            this.conditionallyRedraw(true);
         }
      }
      
      public function showArrowDisplay() : void
      {
         this.m_hideArrow = false;
         if(this.m_arrow == null)
         {
            this.m_arrow = this.generateHarvestArrow();
         }
         this.m_arrow.visible = true;
         if(this.m_arrow)
         {
            (m_displayObject as Sprite).addChild(this.m_arrow);
            this.setArrowPosition();
         }
      }
      
      override public function prepForGameMode(mode:GameMode, activating:Boolean) : void
      {
         if(mode is GMSnapShot)
         {
            if(this.m_arrow)
            {
               this.m_arrow.visible = !activating;
            }
         }
      }
      
      override public function canUpdateCursorOnVisit() : Boolean
      {
         return this.isHarvestable() && isHarvestableByNeighbors() && VisitorManager.getInstance().canPerformAction(this,NeighborActionConstants.LIMIT_TYPE_FARM_ACTION);
      }
      
      override public function setFullGrown() : void
      {
         super.setFullGrown();
         setState(STATE_RIPE);
      }
      
      public function isMasterable() : Boolean
      {
         var item:FarmItem = null;
         var result:Boolean = false;
         if(!isToolGenerated)
         {
            item = this.getMasteryFarmItem();
            if(item is HarvestableItem && (item as HarvestableItem).hasMastery)
            {
               result = true;
            }
         }
         return result;
      }
      
      protected function getMasteryFarmItem() : FarmItem
      {
         return m_item;
      }
      
      override public function getObservableEvents() : Vector.<String>
      {
         var events:Vector.<String> = super.getObservableEvents();
         events.push(OBSERVABLE_EVENT_HARVEST);
         return events;
      }
      
      public function getOriginalItemName() : String
      {
         var itemName:String = getItemName();
         if(this.m_originalName != null && this.m_originalName != itemName)
         {
            itemName = this.m_originalName;
         }
         return itemName;
      }
   }
}

