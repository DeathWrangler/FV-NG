package Widgets.Slots
{
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import Events.GenericPopupEvent;
   import Managers.OrderBoard.CanadaInnovationManager;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Windows.CanadaInnovationMainWindow;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class CanadaInnovationSpecialCandySlot extends ZwSlotFrame
   {
      
      private static const CANDY_COUNT_TF:String = "candy_main_count_tf";
      
      private static const CANDY_SPECNAME_TF:String = "candy_specname_tf";
      
      private static const CANDY_IMAGE_MC:String = "candy_main_icon_mc";
      
      private static const STATION_SKIP_COST:int = 2;
      
      private var m_featureName:String;
      
      private var m_owner:CanadaInnovationMainWindow;
      
      private var m_candyCountTf:ZwTextField;
      
      private var m_candyNameTf:ZwTextField;
      
      private var m_candyIcon:FarmIcon;
      
      private var m_animationMinusMc:MovieClip;
      
      private var m_animationMinusDooberMc:MovieClip;
      
      private var m_animationPlusMc:MovieClip;
      
      private var m_hoverCandyInfoMc:MovieClip;
      
      private var m_candyReq0Mc:MovieClip;
      
      private var m_candyReq0Icon:FarmIcon;
      
      private var m_candyReq1Mc:MovieClip;
      
      private var m_candyReq1Icon:FarmIcon;
      
      private var m_animationMinusTf:ZwTextField;
      
      private var m_animationPlusDooberMc:MovieClip;
      
      private var m_animationPlusTf:ZwTextField;
      
      private var m_skipBt:FarmAnimatedCashButton;
      
      private var m_makeBT:FarmAnimatedTextButton;
      
      private var m_skipMc:MovieClip;
      
      private var m_countDownTf:ZwTextField;
      
      private var m_darkOverlayMc:MovieClip;
      
      private var m_darylay0Mc:MovieClip;
      
      private var m_darylay1Mc:MovieClip;
      
      private var m_slotnumber:int = -1;
      
      private var m_toolTipText:String = "";
      
      private var m_specialCandyName:String;
      
      private var m_stationId:int;
      
      private var m_stationBusy:int;
      
      private var m_baseCandy:String;
      
      private var m_coatCandy:String;
      
      private var m_baseCandyUrl:String;
      
      private var m_coatCandyUrl:String;
      
      private var m_stationTimer:Number;
      
      private var m_returnTimer:Timer;
      
      public function CanadaInnovationSpecialCandySlot(featureName:String, element:DisplayObject, window:CanadaInnovationMainWindow)
      {
         this.m_featureName = featureName;
         this.m_owner = window;
         super(element);
         if(m_element.hasOwnProperty(CANDY_COUNT_TF))
         {
            addWidget(this.m_candyCountTf = new ZwTextField(m_element[CANDY_COUNT_TF],""));
            this.m_candyCountTf.visible = true;
         }
         if(m_element.hasOwnProperty(CANDY_SPECNAME_TF))
         {
            addWidget(this.m_candyNameTf = new ZwTextField(m_element[CANDY_SPECNAME_TF],""));
            this.m_candyNameTf.visible = true;
         }
         if(m_element.hasOwnProperty(CANDY_IMAGE_MC))
         {
            addWidget(this.m_candyIcon = new FarmIcon(m_element[CANDY_IMAGE_MC]));
            this.m_candyIcon.visible = true;
         }
         if(m_element.hasOwnProperty("candy_minus_doober_mc"))
         {
            this.m_animationMinusMc = m_element["candy_minus_doober_mc"] as MovieClip;
            this.m_animationMinusMc.visible = false;
            this.m_animationMinusDooberMc = this.m_animationMinusMc["dooberIcon_minus_mc"] as MovieClip;
            this.m_animationMinusDooberMc.visible = true;
            if(this.m_animationMinusDooberMc.hasOwnProperty("candy_minus_counter_tf"))
            {
               addWidget(this.m_animationMinusTf = new ZwTextField(this.m_animationMinusDooberMc["candy_minus_counter_tf"],"-1"));
               this.m_animationMinusTf.visible = true;
            }
         }
         if(m_element.hasOwnProperty("candy_plus_doober_mc"))
         {
            this.m_animationPlusMc = m_element["candy_plus_doober_mc"] as MovieClip;
            this.m_animationPlusMc.visible = false;
            this.m_animationPlusDooberMc = this.m_animationPlusMc["dooberIcon_plus_mc"] as MovieClip;
            this.m_animationPlusDooberMc.visible = true;
            if(this.m_animationPlusDooberMc.hasOwnProperty("candy_plus_counter_tf"))
            {
               addWidget(this.m_animationPlusTf = new ZwTextField(this.m_animationPlusDooberMc["candy_plus_counter_tf"],"+1"));
               this.m_animationPlusTf.visible = true;
            }
         }
         if(m_element.hasOwnProperty("hover_candy_info_mc"))
         {
            this.m_hoverCandyInfoMc = m_element["hover_candy_info_mc"] as MovieClip;
            this.m_hoverCandyInfoMc.visible = false;
            if(this.m_hoverCandyInfoMc.hasOwnProperty("candy_spec_req_0_mc"))
            {
               this.m_candyReq0Mc = this.m_hoverCandyInfoMc["candy_spec_req_0_mc"] as MovieClip;
               this.m_candyReq0Mc.visible = true;
               if(this.m_candyReq0Mc.hasOwnProperty("candy_req_icon_0_mc"))
               {
                  addWidget(this.m_candyReq0Icon = new FarmIcon(this.m_candyReq0Mc["candy_req_icon_0_mc"]));
                  this.m_candyReq0Icon.visible = true;
               }
               if(this.m_candyReq0Mc.hasOwnProperty("dark_overlay_mc"))
               {
                  this.m_darylay0Mc = this.m_candyReq0Mc["dark_overlay_mc"] as MovieClip;
                  this.m_darylay0Mc.visible = false;
               }
            }
            if(this.m_hoverCandyInfoMc.hasOwnProperty("candy_spec_req_1_mc"))
            {
               this.m_candyReq1Mc = this.m_hoverCandyInfoMc["candy_spec_req_1_mc"] as MovieClip;
               this.m_candyReq1Mc.visible = true;
               if(this.m_candyReq1Mc.hasOwnProperty("candy_req_icon_1_mc"))
               {
                  addWidget(this.m_candyReq1Icon = new FarmIcon(this.m_candyReq1Mc["candy_req_icon_1_mc"]));
                  this.m_candyReq1Icon.visible = true;
               }
               if(this.m_candyReq1Mc.hasOwnProperty("dark_overlay_mc"))
               {
                  this.m_darylay1Mc = this.m_candyReq1Mc["dark_overlay_mc"] as MovieClip;
                  this.m_darylay1Mc.visible = false;
               }
            }
         }
         if(m_element.hasOwnProperty("make_bt"))
         {
            addWidget(this.m_makeBT = new FarmAnimatedTextButton(m_element["make_bt"],"Make x1",this.onCollect));
            this.m_makeBT.visible = false;
            m_element.addEventListener(MouseEvent.MOUSE_OVER,this.onHitAreaMouseRollOver);
            m_element.addEventListener(MouseEvent.MOUSE_OUT,this.onHitAreaMouseRollOut);
         }
         if(m_element.hasOwnProperty("skip_mc"))
         {
            this.m_skipMc = m_element["skip_mc"] as MovieClip;
            this.m_skipMc.visible = false;
            if(this.m_skipMc.hasOwnProperty("buy_bt"))
            {
               addWidget(this.m_skipBt = new FarmAnimatedCashButton(this.m_skipMc["buy_bt"],"Skip Wait",STATION_SKIP_COST.toString(),this.onClickSkipButton));
               this.m_skipBt.visible = false;
            }
            if(this.m_skipMc.hasOwnProperty("countdown_timer_tf"))
            {
               addWidget(this.m_countDownTf = new ZwTextField(this.m_skipMc["countdown_timer_tf"],""));
               this.m_countDownTf.visible = true;
            }
         }
         if(m_element.hasOwnProperty("dark_overlay_mc"))
         {
            this.m_darkOverlayMc = m_element["dark_overlay_mc"] as MovieClip;
            this.m_darkOverlayMc.visible = false;
         }
      }
      
      override public function populate(data:Object) : void
      {
         var baseCount:int = 0;
         var coatCount:int = 0;
         var stationTimer:Number = NaN;
         var timeLeft:int = 0;
         var toolTipText:String = null;
         this.m_toolTipText = "";
         super.populate(data);
         this.m_animationMinusMc.visible = false;
         this.m_animationPlusMc.visible = false;
         this.m_hoverCandyInfoMc.visible = false;
         this.m_darkOverlayMc.visible = false;
         this.m_skipMc.visible = false;
         if(data)
         {
            baseCount = this.manager.getBasicCandyCountByName(data["baseCandyName"]);
            coatCount = this.manager.getBasicCandyCountByName(data["coatCandyName"]);
            this.m_specialCandyName = data["candyName"];
            this.m_stationId = data["stationId"];
            this.m_stationBusy = data["stationBusy"];
            this.m_baseCandy = data["baseCandyName"];
            this.m_baseCandyUrl = data["baseCandyUrl"];
            this.m_coatCandy = data["coatCandyName"];
            this.m_coatCandyUrl = data["coatCandyUrl"];
            if(data.hasOwnProperty("questOrderSlotNumber"))
            {
               this.m_slotnumber = data.questOrderSlotNumber;
            }
            if(data.hasOwnProperty("candyCount"))
            {
               this.m_candyCountTf.text = "x" + data.candyCount;
               this.m_candyCountTf.visible = true;
            }
            if(data.hasOwnProperty("candyIcon"))
            {
               this.m_candyIcon.loadIcon(data.candyIcon);
               this.m_candyIcon.setIconSize(50,50);
               this.m_candyIcon.visible = true;
            }
            if(data.hasOwnProperty("candyName"))
            {
               this.m_candyNameTf.text = data["candyName"];
               this.m_candyNameTf.visible = true;
            }
            if(data.hasOwnProperty("baseCandyName"))
            {
               this.m_candyReq0Icon.loadIcon(data["baseCandyUrl"]);
               this.m_candyReq0Icon.setIconSize(30,30);
               this.m_candyReq0Icon.visible = true;
            }
            if(data.hasOwnProperty("coatCandyName"))
            {
               this.m_candyReq1Icon.loadIcon(data["coatCandyUrl"]);
               this.m_candyReq1Icon.setIconSize(30,30);
               this.m_candyReq1Icon.visible = true;
            }
            if(data["candyCount"] == 0)
            {
               this.m_darkOverlayMc.visible = true;
            }
            if(this.manager.getBasicCandyCountByName(data["baseCandyName"]) == 0)
            {
               this.m_darylay0Mc.visible = true;
            }
            if(this.manager.getBasicCandyCountByName(data["coatCandyName"]) == 0)
            {
               this.m_darylay1Mc.visible = true;
            }
            if(this.m_stationBusy == 1)
            {
               stationTimer = Number(data["stationTimer"]);
               this.m_stationTimer = data["stationTimer"];
               timeLeft = this.manager.getStationMakingTimerLeft(stationTimer);
               if(timeLeft <= 0)
               {
                  this.m_makeBT.text = "Collect";
                  this.m_makeBT.enabled = true;
                  this.m_makeBT.visible = true;
               }
               else
               {
                  this.m_skipMc.visible = true;
                  this.m_countDownTf.text = FarmGameUtil.toFriendlyTime(timeLeft);
                  this.m_countDownTf.visible = true;
                  this.m_skipBt.visible = true;
                  this.m_skipBt.enabled = true;
                  this.startCollectTimer();
               }
            }
            else if(this.m_stationBusy == 0)
            {
               this.m_makeBT.text = "Make";
               this.m_makeBT.visible = true;
               if(baseCount >= 1 && coatCount >= 1)
               {
                  this.m_makeBT.enabled = true;
               }
               else
               {
                  this.m_makeBT.enabled = false;
                  toolTipText = "You don\'t have one or more of the ingredients required";
                  FarmGameUtil.disableButtonAndShowTooltip(this.m_makeBT,toolTipText);
               }
            }
         }
      }
      
      private function onClickSkipButton(event:Event) : void
      {
         var confirmationText:String = ZLocUtils.t("Dialogs","Station_CashBuyConfirmation",{"price":STATION_SKIP_COST});
         if(UI.displayMessage(confirmationText,GenericPopup.TYPE_ACCEPTCANCEL,this.onAcceptSkipConfirmation,"farmAnimatedCashConfirmation",true,true))
         {
            this.m_skipBt.enabled = false;
            this.m_owner.tintWindow();
            this.m_owner.enableInput = false;
         }
      }
      
      private function onAcceptSkipConfirmation(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.ACCEPT)
         {
            this.manager.onStationBuyBT(STATION_SKIP_COST,this.m_stationId);
         }
         else
         {
            this.m_skipBt.enabled = true;
            this.m_owner.untintWindow();
            this.m_owner.enableInput = true;
         }
      }
      
      private function onCollect(event:Event) : void
      {
         if(this.m_makeBT.visible && this.m_makeBT.enabled)
         {
            this.m_makeBT.enabled = false;
            if(this.m_makeBT.text == "Collect")
            {
               this.manager.onCollectSpecialCandy(this.m_specialCandyName,this.m_slotnumber);
            }
            else if(this.m_makeBT.text == "Make")
            {
               this.manager.makeSpecialCandy(this.m_specialCandyName,this.m_stationId,this.m_baseCandy,this.m_coatCandy);
            }
         }
      }
      
      private function onHitAreaMouseRollOver(event:MouseEvent) : void
      {
         this.m_hoverCandyInfoMc.visible = true;
      }
      
      private function onHitAreaMouseRollOut(event:MouseEvent) : void
      {
         this.m_hoverCandyInfoMc.visible = false;
      }
      
      private function startCollectTimer() : void
      {
         this.m_returnTimer = new Timer(1000);
         this.m_returnTimer.addEventListener(TimerEvent.TIMER,this.onStartCollectTimer);
         this.m_returnTimer.start();
      }
      
      public function onStartCollectTimer(event:TimerEvent) : void
      {
         var timeLeft:int = this.manager.getStationMakingTimerLeft(this.m_stationTimer);
         if(timeLeft > 0)
         {
            this.m_skipMc.visible = true;
            this.m_countDownTf.text = FarmGameUtil.toFriendlyTime(timeLeft);
            this.m_countDownTf.visible = true;
            this.m_skipBt.visible = true;
         }
         else
         {
            this.stopCollectTimer();
            this.manager.refreshSpecialCandySlot(this.m_slotnumber);
         }
      }
      
      public function stopCollectTimer() : void
      {
         if(this.m_returnTimer)
         {
            this.m_returnTimer.stop();
            this.m_returnTimer.removeEventListener(TimerEvent.TIMER,this.onStartCollectTimer);
            this.m_returnTimer = null;
         }
      }
      
      private function get manager() : CanadaInnovationManager
      {
         return CanadaInnovationManager.getInstance(this.m_featureName);
      }
   }
}

