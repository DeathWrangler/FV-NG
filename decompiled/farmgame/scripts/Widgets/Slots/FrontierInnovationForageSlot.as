package Widgets.Slots
{
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import Events.GenericPopupEvent;
   import Managers.OrderBoard.FrontierInnovationManager;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.FrontierInnovationForageCompleteResourceFrame;
   import Widgets.Frames.FrontierInnovationForageResourceFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.FarmTextTooltip;
   import Widgets.Windows.FrontierInnovationWindow;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class FrontierInnovationForageSlot extends ZwSlotFrame
   {
      
      private static const ICON_SIZE:int = 100;
      
      protected var m_iconPreview:FarmIcon;
      
      private var m_checkMark:ZwWidget;
      
      private var m_areaTf:ZwTextField;
      
      private var m_pointsTf:ZwTextField;
      
      private var m_rewardBg:ZwWidget;
      
      private var m_commonRewardBg:ZwWidget;
      
      private var infoTooltip:FarmTextTooltip;
      
      private var m_checkmark:MovieClip;
      
      private var m_iconMc:FarmIcon;
      
      private var m_countTf:ZwTextField;
      
      private var m_selectTf:ZwTextField;
      
      private var m_hoverMc:ZwFrame;
      
      private var m_discardBt:FarmAnimatedTextButton;
      
      private var m_tradeBt:FarmAnimatedTextButton;
      
      private var m_okayBt:FarmAnimatedTextButton;
      
      private var m_skipBt:FarmAnimatedCashButton;
      
      private var m_timeLeftTf:ZwTextField;
      
      private var m_sparkleMc:MovieClip;
      
      private var m_sinkHoverTooltip:FarmTextTooltip;
      
      private var m_axeMc:MovieClip;
      
      private var m_clockMc:MovieClip;
      
      private const SPARKLE_MC:String = "sparkle_mc";
      
      private const ICON_MC:String = "icon_mc";
      
      private const OKAY_BT:String = "okay_bt";
      
      private const COUNT_TF:String = "count_tf";
      
      private const CHECKMARK_MC:String = "checkmark_mc";
      
      private const SELECT_TF:String = "select_tf";
      
      private const OVERLAY_MC:String = "overlay1_mc";
      
      private const EMPTY_SLOT:int = -1;
      
      private const AREA_TF:String = "area_tf";
      
      private const AXE_MC:String = "axe_mc";
      
      private const POINTS_TF:String = "points_tf";
      
      private const CLOCK_MC:String = "clock_mc";
      
      private const RESOURCES_MC:String = "resources_mc";
      
      private const BUY_BT:String = "buy_bt";
      
      private const TIMELEFT_TF:String = "timeleft_tf";
      
      private const RESOURCES_FORAGE_GRANT_COUNT:* = 3;
      
      private var manager:FrontierInnovationManager;
      
      private var m_timeRequired:int;
      
      private var m_TS:Number;
      
      private var m_status:int;
      
      private var m_fc:int;
      
      private var m_featureName:String;
      
      private var m_frameName:String;
      
      public var m_areaId:int;
      
      private var m_window:FrontierInnovationWindow;
      
      private var m_overlayMc:MovieClip;
      
      private var m_completeResourceFrame:FrontierInnovationForageCompleteResourceFrame;
      
      private var m_resourceFrame:FrontierInnovationForageResourceFrame;
      
      private var patternSlot:RegExp = /\d/;
      
      private var m_confirmPopup:GenericPopup;
      
      public function FrontierInnovationForageSlot(featureName:String, element:DisplayObject, window:FrontierInnovationWindow)
      {
         this.m_featureName = featureName;
         this.m_window = window;
         this.manager = FrontierInnovationManager.getInstance(featureName);
         super(element);
         this.m_frameName = m_element.name;
         this.m_areaId = this.getAreaId(this.m_frameName);
         if(m_element.hasOwnProperty(this.AREA_TF))
         {
            this.m_areaTf = addWidget(new ZwTextField(m_element[this.AREA_TF],"")) as ZwTextField;
            this.m_areaTf.visible = true;
         }
         if(m_element.hasOwnProperty(this.AXE_MC))
         {
            this.m_axeMc = m_element[this.AXE_MC] as MovieClip;
            this.m_axeMc.visible = true;
            if(this.m_axeMc.hasOwnProperty(this.POINTS_TF))
            {
               this.m_pointsTf = addWidget(new ZwTextField(this.m_axeMc[this.POINTS_TF],"")) as ZwTextField;
               this.m_pointsTf.visible = true;
            }
         }
         if(m_element.hasOwnProperty(this.ICON_MC))
         {
            addWidget(this.m_iconMc = new FarmIcon(m_element[this.ICON_MC]));
            this.m_iconMc.visible = true;
            if(this.m_iconMc.hasOwnProperty(this.SPARKLE_MC))
            {
               this.m_sparkleMc = this.m_iconMc[this.SPARKLE_MC] as MovieClip;
               this.m_sparkleMc.visible = true;
            }
         }
         if(m_element.hasOwnProperty(this.OKAY_BT))
         {
            addWidget(this.m_okayBt = new FarmAnimatedTextButton(m_element[this.OKAY_BT],"",this.onForageClick));
            this.m_okayBt.visible = true;
         }
         if(m_element.hasOwnProperty(this.RESOURCES_MC))
         {
            this.m_resourceFrame = new FrontierInnovationForageResourceFrame(m_element[this.RESOURCES_MC],this.m_featureName,this.m_window,this.m_areaId);
            this.m_resourceFrame.visible = false;
         }
         if(m_element.hasOwnProperty(this.CLOCK_MC))
         {
            this.m_clockMc = m_element[this.CLOCK_MC] as MovieClip;
         }
         if(m_element.hasOwnProperty(this.BUY_BT))
         {
            addWidget(this.m_skipBt = new FarmAnimatedCashButton(m_element[this.BUY_BT],"Skip Wait","",this.onClickSkipButton));
         }
         if(m_element.hasOwnProperty(this.TIMELEFT_TF))
         {
            this.m_timeLeftTf = addWidget(new ZwTextField(m_element[this.TIMELEFT_TF],"")) as ZwTextField;
         }
         if(m_element.hasOwnProperty(this.OVERLAY_MC))
         {
            this.m_overlayMc = m_element[this.OVERLAY_MC] as MovieClip;
            this.m_overlayMc.visible = false;
         }
      }
      
      override public function populate(data:Object) : void
      {
         var timeLeft:int = 0;
         super.populate(data);
         this.m_areaTf.text = data["area"];
         this.m_areaTf.visible = true;
         this.m_pointsTf.text = data["pickaxeRequired"];
         this.m_timeRequired = data["timeRequired"];
         this.m_TS = data["TS"];
         this.m_fc = data["FC"];
         this.m_status = data["status"];
         this.m_skipBt.enabled = true;
         this.m_clockMc.visible = false;
         this.m_overlayMc.visible = false;
         var iconUrl:String = Global.getAssetURL(data["areaImage"]);
         this.m_iconMc.loadIcon(iconUrl);
         this.m_iconMc.setIconSize(100,100);
         this.m_iconMc.visible = true;
         var pickaxeRequired:int = int(data["pickaxeRequired"]);
         var pickaxCount:int = this.manager.getOrderboardProgress();
         if(this.m_TS == -1 && this.m_status == 0)
         {
            this.setForageVisibility(pickaxCount,pickaxeRequired);
         }
         else if(this.m_TS == -1 && this.m_status == 1)
         {
            this.m_okayBt.text = "Redeem";
            this.m_okayBt.visible = true;
            this.m_axeMc.visible = false;
            this.m_pointsTf.visible = false;
         }
         else
         {
            timeLeft = this.getForageTimeLeft(this.m_TS);
            if(timeLeft >= this.m_timeRequired)
            {
               this.setForageVisibility(pickaxCount,pickaxeRequired);
            }
            else
            {
               this.m_axeMc.visible = false;
               this.m_overlayMc.visible = true;
               this.m_resourceFrame.visible = false;
               this.m_skipBt.visible = true;
               this.m_clockMc.visible = true;
               this.m_skipBt.setAmountText(String(this.m_fc));
               this.m_timeLeftTf.text = "You can Forage again in " + String(this.m_timeRequired - timeLeft) + " minutes";
               this.m_timeLeftTf.visible = true;
            }
         }
         this.m_resourceFrame.refresh();
      }
      
      private function setForageVisibility(pickaxCount:int, pickaxeRequired:int) : void
      {
         var toolTipText:String = null;
         this.m_okayBt.text = "Forage";
         this.m_okayBt.visible = true;
         this.m_axeMc.visible = true;
         this.m_pointsTf.visible = true;
         this.m_okayBt.enabled = pickaxCount >= pickaxeRequired;
         this.m_skipBt.visible = false;
         this.m_timeLeftTf.visible = false;
         this.m_resourceFrame.visible = true;
         if(!this.m_okayBt.visible)
         {
            toolTipText = "Complete orders and collect more Pickaxes to go Foraging!";
            FarmGameUtil.disableButtonAndShowTooltip(this.m_okayBt,toolTipText);
         }
      }
      
      public function getAreaId(areaName:String) : int
      {
         var result:Object = this.patternSlot.exec(areaName);
         return int(result[0]);
      }
      
      private function onForageClick(event:Event) : void
      {
         var buttonCheck:String = this.m_okayBt.text.toString();
         var capacityRemain:int = this.manager.getRemainBarnCapacity();
         if(this.m_window)
         {
            this.m_window.unsetForcedTut();
         }
         if(capacityRemain >= this.RESOURCES_FORAGE_GRANT_COUNT)
         {
            this.m_axeMc.visible = false;
            this.m_okayBt.enabled = false;
            this.m_pointsTf.visible = false;
            this.m_window.setForageOverlayMc(true);
            this.m_skipBt.enabled = false;
            this.manager.onForgeClick(this.m_areaId);
         }
         else
         {
            this.m_window.setForageOverlayMc(true);
            this.visitBarnPopUp();
         }
      }
      
      private function getForageTimeLeft(givenTime:int) : int
      {
         var currentTime:Number = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
         return int(Math.abs(currentTime - givenTime) / FarmGameUtil.NUM_SECS_IN_MINUTE);
      }
      
      private function onClickSkipButton(event:Event) : void
      {
         var confirmationText:String = ZLocUtils.t("Dialogs","ForageArea_CashBuyConfirmation",{"price":this.m_fc});
         if(UI.displayMessage(confirmationText,GenericPopup.TYPE_ACCEPTCANCEL,this.onAcceptSkipConfirmation,"farmAnimatedCashConfirmation",true,true))
         {
            this.m_skipBt.enabled = false;
            this.m_window.setForageOverlayMc(true);
         }
      }
      
      private function onAcceptSkipConfirmation(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.ACCEPT)
         {
            this.manager.onForageByPayFC(this.m_fc,this.m_areaId);
         }
         else
         {
            this.m_skipBt.enabled = true;
            this.m_window.setForageOverlayMc(false);
         }
      }
      
      public function visitBarnPopUp() : void
      {
         var sellMessage:String = "You do not have enough space in the Barnhouse. Please discard resources or upgrade it to get more capacity.";
         this.m_confirmPopup = new GenericPopup(sellMessage,GenericPopup.TYPE_OK,this.onVisitBarn);
         this.m_confirmPopup.setAcceptTextName("VisitBarnHouse");
         UI.displayPopup(this.m_confirmPopup,false,"Barn_Capacity_Full",true);
      }
      
      public function onVisitBarn(evt:GenericPopupEvent) : void
      {
         this.m_window.setForageOverlayMc(false);
         this.manager.m_window.disableForageWindow();
         this.manager.visitBarnUIFromForage();
      }
   }
}

