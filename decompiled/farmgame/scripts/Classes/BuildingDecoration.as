package Classes
{
   import Classes.Constants.CrossPromoConstants;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.ContextMenuItem;
   import Display.CrossPromoMailboxDialog;
   import Display.FarmDynamicDialog;
   import Display.UI;
   import Engine.Managers.StatsManager;
   import GameMode.GMBuild;
   import MyLife.Events.GlobalEventManager;
   import Widgets.Windows.ArrowIndicatorWindow;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.utils.getDefinitionByName;
   
   public class BuildingDecoration extends Decoration
   {
      
      private static var m_classCompilingArray:Array = [CrossPromoMailboxDialog];
      
      public static const CROSS_PROMO_DATA_LOADED:String = "onDataLoaded";
      
      private var m_crossGameGifting:Object = new Object();
      
      private const ARROW_INDICATOR_RECEIVED:String = "item_received";
      
      private const ARROW_INDICATOR_CAN_SEND:String = "can_send";
      
      private const ARROW_INDICATOR_NONE:String = "none";
      
      protected var m_arrow:DisplayObject;
      
      protected var m_hideArrow:Boolean = false;
      
      protected var m_arrowCurrentlyHidden:Boolean = true;
      
      protected var m_gameID:String = "";
      
      public function BuildingDecoration(itemName:String = null)
      {
         super(itemName);
         this.m_gameID = Global.farmGameSettingsManager.getGameIDByItemName(m_item.name);
         this.m_crossGameGifting = Global.player.getCrossGameGiftingStateData(this.m_gameID);
         if(this.m_crossGameGifting == null)
         {
            GlobalEventManager.getInstance().addEventListener(CROSS_PROMO_DATA_LOADED,this.onCrossGameDataLoaded);
         }
      }
      
      private function onCrossGameDataLoaded(event:Event) : void
      {
         this.m_crossGameGifting = Global.player.getCrossGameGiftingStateData(this.m_gameID);
         this.checkArrowIndicator();
         GlobalEventManager.getInstance().removeEventListener(CROSS_PROMO_DATA_LOADED,this.onCrossGameDataLoaded);
      }
      
      override protected function getMenuItems() : Array
      {
         return [{
            "label":ZLocUtils.t("FarmGame","LookInside"),
            "action":LOOK_INSIDE
         },{
            "label":ZLocUtils.t("FarmGame","Move"),
            "action":MOVE_OBJECT
         },{
            "label":ZLocUtils.t("FarmGame","Sell"),
            "action":SELL_OBJECT
         }];
      }
      
      override public function onMenuClick(event:MouseEvent) : void
      {
         var item:ContextMenuItem = null;
         this.removeArrowIndicator();
         if(event.target is ContextMenuItem)
         {
            item = event.target as ContextMenuItem;
            switch(item.action)
            {
               case LOOK_INSIDE:
                  this.openDialog();
                  break;
               default:
                  super.onMenuClick(event);
            }
         }
         Global.player.setSeenSessionFlag("clickedArrow" + this.m_gameID);
      }
      
      private function canSendGift() : Boolean
      {
         var serverTime:Number = NaN;
         var canSend:Boolean = false;
         if(this.m_crossGameGifting != null && this.m_crossGameGifting[CrossPromoMailboxDialog.LAST_SENT] != null)
         {
            serverTime = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
            if(serverTime - this.m_crossGameGifting[CrossPromoMailboxDialog.LAST_SENT] > CrossPromoMailboxDialog.MAX_SEND_TIME)
            {
               canSend = true;
            }
         }
         else
         {
            canSend = true;
         }
         return canSend;
      }
      
      private function hasReceivedGifts() : Boolean
      {
         var receivedGifts:Boolean = false;
         if(this.m_crossGameGifting != null && this.m_crossGameGifting.hasOwnProperty(CrossPromoMailboxDialog.RECEIVED_GIFTS) && this.m_crossGameGifting[CrossPromoMailboxDialog.RECEIVED_GIFTS] != null)
         {
            receivedGifts = true;
         }
         return receivedGifts;
      }
      
      override public function onFinishPlace(transactionResult:Object = null) : void
      {
         this.openDialog();
         StatsManager.count("xpromo_crossGifting_" + CrossPromoConstants.CITY_GAME_ID,"place_first_time");
      }
      
      override protected function replaceContent(newContent:DisplayObject, shouldRedrawMask:Boolean = false) : void
      {
         super.replaceContent(newContent,shouldRedrawMask);
         if(Boolean(this.m_arrow) && !this.m_hideArrow)
         {
            (m_displayObject as Sprite).addChild(this.m_arrow);
            this.setArrowPosition();
         }
         if(this.m_crossGameGifting != null)
         {
            this.checkArrowIndicator();
         }
      }
      
      private function checkArrowIndicator() : void
      {
         var arrowIndicatorType:String = null;
         var spr:Sprite = null;
         if(!m_usingLoadingGraphic)
         {
            arrowIndicatorType = this.getArrowIndicatorType();
            this.m_hideArrow = this.ARROW_INDICATOR_NONE == arrowIndicatorType;
            if(this.m_arrowCurrentlyHidden != this.m_hideArrow)
            {
               if(this.m_hideArrow)
               {
                  this.removeArrowIndicator();
               }
               else
               {
                  spr = m_displayObject as Sprite;
                  if(this.m_arrow == null && spr.numChildren > 0)
                  {
                     this.m_arrow = this.createArrowIndicator(arrowIndicatorType);
                     if(this.m_arrow)
                     {
                        this.m_arrow.visible = true;
                        (m_displayObject as Sprite).addChild(this.m_arrow);
                        this.setArrowPosition();
                     }
                     this.m_arrowCurrentlyHidden = false;
                  }
               }
            }
         }
      }
      
      private function createArrowIndicator(arrowIndicatorType:String) : DisplayObject
      {
         var arrowIndicator:DisplayObject = null;
         var iconUrl:String = "assets/decorations/giftIcon.png";
         var counter:int = 0;
         var canShowCounterIcon:Boolean = false;
         var title:String = "";
         var text:String = "";
         switch(arrowIndicatorType)
         {
            case this.ARROW_INDICATOR_RECEIVED:
               title = ZLocUtils.t("Dialogs",m_item.name + "_tooltip_received_title");
               text = ZLocUtils.t("Dialogs",m_item.name + "_tooltip_received_text");
               break;
            case this.ARROW_INDICATOR_CAN_SEND:
               title = ZLocUtils.t("Dialogs",m_item.name + "_tooltip_send_title");
               text = ZLocUtils.t("Dialogs",m_item.name + "_tooltip_send_text");
         }
         return new ArrowIndicatorWindow(iconUrl,title,text);
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
            arrowIndicatorWindow = this.m_arrow as ArrowIndicatorWindow;
            if(arrowIndicatorWindow)
            {
               arrowIndicatorWindow.showRolloverText(isHighlighted());
            }
         }
      }
      
      private function getArrowIndicatorType() : String
      {
         var hasSeenArrow:Boolean = false;
         var type:String = this.ARROW_INDICATOR_NONE;
         var currentGMs:Array = Global.world.getActiveGameModes();
         if(!(Global.worldManager.isVisiting() || currentGMs[0] is GMBuild || UI.isShowingPopup()))
         {
            hasSeenArrow = Global.player.getSeenSessionFlag("clickedArrow" + this.m_gameID);
            if(!hasSeenArrow && this.hasReceivedGifts())
            {
               type = this.ARROW_INDICATOR_RECEIVED;
            }
            else if(!hasSeenArrow && this.canSendGift())
            {
               type = this.ARROW_INDICATOR_CAN_SEND;
            }
         }
         return type;
      }
      
      public function removeArrowIndicator() : void
      {
         if(Boolean(this.m_arrow) && Boolean(this.m_arrow.visible) && this.m_arrow.parent != null)
         {
            this.m_arrow.visible = false;
            this.m_arrow.parent.removeChild(this.m_arrow);
            this.m_arrow = null;
            conditionallyRedraw(true);
            this.m_arrowCurrentlyHidden = true;
            this.m_hideArrow = true;
         }
      }
      
      protected function setArrowPosition() : void
      {
         if(Boolean(this.m_arrow) && Boolean(m_displayObject))
         {
            this.m_arrow.x = m_displayObject.width * 0.5;
            this.m_arrow.y = this.m_arrow.height - m_displayObject.height - 60;
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
            this.conditionallyRedraw(true);
         }
      }
      
      public function openDialog() : void
      {
         var dialogClass:String = null;
         var dialogName:String = null;
         var objectClass:Class = null;
         var dialog:FarmDynamicDialog = null;
         if(Global.experimentManager.getExperimentVariant("fv_cross_gifting_" + this.m_gameID) > 1)
         {
            dialogClass = this.getItem().dialogClass;
            dialogName = this.getItem().dialogName;
            if(dialogName != "" && dialogClass != "")
            {
               objectClass = getDefinitionByName(dialogClass) as Class;
               dialog = FarmDynamicDialog.createDialog(dialogName,objectClass);
               dialog.setup();
               dialog.show();
            }
         }
         else
         {
            UI.displayMessage(ZLocUtils.t("Dialogs","ComingSoonCityXGifting"),0,null,"",true);
         }
      }
   }
}

