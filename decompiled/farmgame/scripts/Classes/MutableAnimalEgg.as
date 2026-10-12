package Classes
{
   import Classes.FeatureDataObjects.MysteryEggFriendSet;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.ContextMenuItem;
   import Display.GenericIconPopup;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Helpers.Vector2;
   import Engine.Managers.TransactionManager;
   import Events.GenericPopupEvent;
   import Managers.FarmStatsManager;
   import Transactions.TTransformBuilding;
   import Widgets.Windows.ArrowIndicatorWindow;
   import Widgets.Windows.Breeding.MutableAnimalEggThankYouWindow;
   import Widgets.Windows.Breeding.MutableAnimalEggWindow;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   
   public class MutableAnimalEgg extends ConstructionBuilding
   {
      
      public static const MYSTERY_EGG_FRIENDSET_CODE:String = "FS09";
      
      protected static const OVERLAY_URL:String = "assets/effects/effect_mysterycrate.swf";
      
      private static const OVERLAY_OFFSET:Vector2 = new Vector2(10,40);
      
      private static const OVERLAY_SCALE:Number = 4;
      
      private const STATE_STATIC:String = "static";
      
      protected const ASK_FOR_HELP:String = "askForHelp";
      
      protected const SPEED_UP_EGG:String = "speedUpEgg";
      
      protected const COMPLETE_NOW:String = "completeNow";
      
      protected const ARROW_NONE:int = 0;
      
      protected const ARROW_READY:int = 1;
      
      protected const ARROW_REMINDER:int = 2;
      
      private var m_showingArrow:int = 0;
      
      private var m_shouldCheckArrow:Boolean = false;
      
      protected var m_adultCode:String = "";
      
      protected var m_friendSetID:int;
      
      private var m_finalFriendReceiveTime:int;
      
      private var m_friendSet:MysteryEggFriendSet;
      
      public function MutableAnimalEgg(buildingType:String = null)
      {
         super(buildingType);
         setState(this.STATE_STATIC);
      }
      
      override public function loadObject(data:Object) : void
      {
         super.loadObject(data);
         if(data.hasOwnProperty("adultCode") && data.adultCode != null && data.adultCode != "")
         {
            this.m_adultCode = data.adultCode;
         }
         if(data.hasOwnProperty("friendSetIndex") && data.friendSetIndex != null && data.friendSetIndex != -2 && Boolean(data.friendSet))
         {
            this.m_friendSetID = data.friendSetIndex;
            this.m_finalFriendReceiveTime = data.friendSet.finalFriendReceiveTime;
            this.m_friendSet = new MysteryEggFriendSet(MYSTERY_EGG_FRIENDSET_CODE,this.m_friendSetID);
            this.m_friendSet.onInitialize(data.friendSet);
            this.m_shouldCheckArrow = true;
         }
      }
      
      override public function onBuildComplete(transactionResult:Object) : void
      {
         setState(STATE_CONSTRUCTION);
         if(transactionResult.hasOwnProperty("adultCode") && transactionResult.adultCode != null && transactionResult.adultCode != "")
         {
            this.m_adultCode = transactionResult.adultCode;
         }
         if(transactionResult.hasOwnProperty("friendSetIndex") && transactionResult.friendSetIndex != null)
         {
            this.m_friendSetID = transactionResult.friendSetId;
            this.m_finalFriendReceiveTime = transactionResult.friendSet.finalFriendReceiveTime;
            this.m_friendSet = new MysteryEggFriendSet(MYSTERY_EGG_FRIENDSET_CODE,this.m_friendSetID);
            this.m_friendSet.onInitialize(transactionResult.friendSet);
         }
      }
      
      override protected function updateToolTipText() : void
      {
         var calcTime:Number = NaN;
         var daysLeft:int = 0;
         var hoursLeft:int = 0;
         var minsLeft:int = 0;
         var toolTip:String = null;
         if(isHighlighted())
         {
            if(!isBuildingExperimentLocked() && Global.worldManager.isVisiting() == false && this.m_friendSet != null)
            {
               toolTip = ZLocUtils.tk_pk_asTitle(m_item.friendlyName) + "\n";
               calcTime = this.timeRemaining();
               if(calcTime > 0)
               {
                  daysLeft = calcTime / FarmGameUtil.NUM_SECS_IN_DAY;
                  hoursLeft = calcTime / FarmGameUtil.NUM_SECS_IN_HOUR % FarmGameUtil.NUM_HOURS_IN_DAY;
                  if(daysLeft <= 0)
                  {
                     minsLeft = calcTime / FarmGameUtil.NUM_SECS_IN_MINUTE % FarmGameUtil.NUM_MINUTES_IN_HOUR;
                     toolTip += ZLocUtils.t("Dialogs","AviaryEggTooltipTimeHoursMins",{
                        "hoursNum":hoursLeft,
                        "minsNum":minsLeft
                     });
                  }
                  else
                  {
                     toolTip += ZLocUtils.t("Dialogs","AviaryEggTooltipTimeDaysHours",{
                        "daysNum":daysLeft,
                        "hoursNum":hoursLeft
                     });
                  }
               }
               else
               {
                  toolTip += ZLocUtils.t("Dialogs","LonelyAnimal_TooltipComplete");
               }
            }
            else
            {
               toolTip = ZLocUtils.tk_pk_asTitle(m_item.friendlyName);
            }
            if(state == STATE_BUILT)
            {
               toolTip = ZLocUtils.tk_pk_asTitle(getBuiltToolTipText());
            }
         }
         setToolTip(toolTip);
         updateToolTipPosition();
      }
      
      override public function getOverlayUrl() : String
      {
         return OVERLAY_URL;
      }
      
      override protected function getOverlayOffset() : Vector2
      {
         return OVERLAY_OFFSET;
      }
      
      override protected function getOverlayScale() : Number
      {
         return OVERLAY_SCALE;
      }
      
      override public function getCurrentImageName() : String
      {
         return this.STATE_STATIC;
      }
      
      override public function showMenu() : void
      {
         if(!isBuildingExperimentLocked())
         {
            if(!m_isFullyBuilt)
            {
               m_menuItems.push({
                  "label":ZLocUtils.t("Dialogs","CompleteNowCamel"),
                  "action":this.COMPLETE_NOW
               });
               super.showMenu();
            }
         }
         else
         {
            super.showMenu();
         }
      }
      
      override public function canRotate() : Boolean
      {
         return false;
      }
      
      private function onAskForHelp() : void
      {
         UI.displayPopup(new MutableAnimalEggWindow({"fsId":this.m_friendSetID}));
      }
      
      override public function onCompleteNow() : void
      {
         UI.displayMessage(ZLocUtils.t("Dialogs",m_dialogName + "CompleteNow",{"quantity":this.calculateCashNeeded()}),GenericPopup.TYPE_ACCEPTCANCEL,this.onAcceptCompleteNowPopup);
      }
      
      override public function getFinishedItem() : FarmItem
      {
         return Global.farmGameSettingsManager.getFarmItemByCode(this.m_adultCode);
      }
      
      override protected function checkIfTransformIsPlaceable() : Boolean
      {
         return Global.flashHotParams["FARM_MUTABLEEGG_OOS_FIX_TEMPRT"] as Boolean;
      }
      
      override public function onFullyFinished(result:Object, transformedObj:MapResource = null) : void
      {
         var adultItem:FarmItem = null;
         var item:FarmItem = this.getItem();
         if(transformedObj != null)
         {
            UI.displayPopup(new MutableAnimalEggThankYouWindow({
               "fsId":this.m_friendSetID,
               "adultCode":this.m_adultCode,
               "rewardLink":result.rewardLink,
               "feedAction":m_buildingName
            }));
         }
         else
         {
            adultItem = Global.farmGameSettingsManager.getFarmItemByCode(this.m_adultCode);
            UI.displayPopup(new GenericIconPopup(ZLocUtils.t("Dialogs","EggAdultInGiftbox",{"animal":adultItem.friendlyTitle}),GenericPopup.TYPE_OK,null,adultItem.icon));
         }
      }
      
      private function onSpeedUpEgg() : void
      {
         UI.displayPopup(new MutableAnimalEggWindow({
            "fsId":this.m_friendSetID,
            "item":this.getItem()
         }));
      }
      
      protected function onAcceptCompleteNowPopup(event:GenericPopupEvent) : void
      {
         var cashCost:int = 0;
         if(event.button == GenericPopup.YES)
         {
            cashCost = this.calculateCashNeeded();
            if(Global.player.canBuyCash(cashCost))
            {
               Global.player.cash -= cashCost;
               this.doTransform();
            }
            FarmStatsManager.count(getItem().statsCounter,"maturation","complete_now","accept",cashCost.toString());
         }
         else
         {
            FarmStatsManager.count(getItem().statsCounter,"maturation","complete_now","cancel");
         }
      }
      
      protected function doTransform() : void
      {
         if(!m_isFullyBuilt)
         {
            m_isFullyBuilt = true;
            state = STATE_BUILT;
            this.dispOverlay(this.getOverlayUrl());
            TransactionManager.addTransaction(new TTransformBuilding(this,true));
         }
      }
      
      protected function calculateCashNeeded() : int
      {
         var hours:Number = 0;
         var result:int = 0;
         var cashHalfDay:int = 2;
         if(this.m_friendSet != null)
         {
            hours = this.timeRemaining() / FarmGameUtil.NUM_SECS_IN_HOUR;
            result = Math.ceil(hours / 12) * cashHalfDay;
         }
         return result;
      }
      
      override public function onMenuClick(event:MouseEvent) : void
      {
         var item:ContextMenuItem = null;
         if(event.target is ContextMenuItem)
         {
            item = event.target as ContextMenuItem;
            switch(item.action)
            {
               case this.ASK_FOR_HELP:
                  this.onAskForHelp();
                  break;
               case this.COMPLETE_NOW:
                  this.onCompleteNow();
                  break;
               case this.SPEED_UP_EGG:
                  this.onSpeedUpEgg();
                  break;
               default:
                  super.onMenuClick(event);
            }
         }
      }
      
      private function timeRemaining() : Number
      {
         var calcTime:int = this.m_finalFriendReceiveTime > 0 ? this.m_finalFriendReceiveTime : int(GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND);
         if(null != this.m_friendSet && this.m_friendSet.initialized)
         {
            calcTime = Math.max(0,this.m_friendSet.timeRemaining - (calcTime - this.m_friendSet.getStartTime()));
         }
         else
         {
            calcTime = FarmGameUtil.NUM_SECS_IN_DAY * 3;
         }
         return calcTime;
      }
      
      override public function onUpdate(delta:Number) : void
      {
         super.onUpdate(delta);
         if(this.m_shouldCheckArrow)
         {
            this.checkShowArrow();
         }
      }
      
      override public function onClick() : void
      {
         if(!isBuildingExperimentLocked())
         {
            if(this.ARROW_NONE != this.m_showingArrow)
            {
               this.hideArrowDisplay();
            }
            if(this.timeRemaining() <= 0 && !m_isFullyBuilt)
            {
               FarmStatsManager.count(getItem().statsCounter,"maturation","complete_click");
               this.doTransform();
            }
         }
         super.onClick();
      }
      
      private function checkShowArrow() : void
      {
         if(!isBuildingExperimentLocked() && !Global.worldManager.isVisiting())
         {
            if(this.timeRemaining() <= 0)
            {
               this.generateArrowIndicator(this.ARROW_READY);
            }
         }
         this.m_shouldCheckArrow = false;
      }
      
      private function generateArrowIndicator(arrowType:int) : Boolean
      {
         var sprite:Sprite = null;
         var iconPath:String = null;
         var title:String = null;
         var text:String = null;
         var success:Boolean = false;
         sprite = m_displayObject as Sprite;
         if(m_arrow == null && sprite.numChildren > 0)
         {
            this.m_hideArrow = false;
            iconPath = this.m_item.icon;
            title = ZLocUtils.t("Dialogs","AnimalBreedingAviary_ArrowReady_Title");
            text = ZLocUtils.t("Dialogs","AnimalBreedingAviary_ArrowReady_Text");
            m_arrow = new ArrowIndicatorWindow(iconPath,title,text);
            if(m_arrow != null)
            {
               m_arrow.visible = true;
               sprite.addChild(m_arrow);
               this.setArrowPosition();
               this.m_showingArrow = arrowType;
               success = true;
            }
         }
         return success;
      }
      
      override public function hideArrowDisplay() : void
      {
         if(Boolean(m_arrow) && Boolean(m_arrow.visible) && m_arrow.parent != null)
         {
            m_arrow.visible = false;
            m_arrow.parent.removeChild(m_arrow);
            m_arrow = null;
            conditionallyRedraw(true);
            this.m_showingArrow = this.ARROW_NONE;
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
      
      private function updateArrowIndicator() : void
      {
         var arrowIndicatorWindow:ArrowIndicatorWindow = null;
         if(Global.selectedAvatar)
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

