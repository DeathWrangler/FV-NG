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
   import Widgets.Tooltips.FarmTextTooltip;
   import Widgets.Windows.CanadaInnovationMainWindow;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class CanadaInnovationStationSlot extends ZwSlotFrame
   {
      
      private static const STATION_SKIP_COST:int = 2;
      
      private var m_owner:CanadaInnovationMainWindow;
      
      private const FEATURE_NAME:String = "CanadaInnovation";
      
      private var m_slotNumber:Number;
      
      private var m_candyReadyMc:MovieClip;
      
      private var m_skipBt:FarmAnimatedCashButton;
      
      private var m_candyReadyIcon:FarmIcon;
      
      private var m_candyReadyTryIcon:FarmIcon;
      
      private var m_candyReadyTf:ZwTextField;
      
      private var m_candyTryMc:MovieClip;
      
      private var m_candyRcipesTf:ZwTextField;
      
      private var m_candyReadyBT:FarmAnimatedTextButton;
      
      private var m_recipeBookBt:FarmAnimatedTextButton;
      
      private var m_specialCandyName:String;
      
      private var m_stationId:int;
      
      private var m_stationBusy:int;
      
      public function CanadaInnovationStationSlot(element:DisplayObject, window:CanadaInnovationMainWindow)
      {
         super(element);
         this.m_owner = window;
         this.visible = true;
         if(m_element.hasOwnProperty("candy_ready_mc"))
         {
            this.m_candyReadyMc = m_element["candy_ready_mc"] as MovieClip;
            this.m_candyReadyMc.visible = false;
            if(this.m_candyReadyMc.hasOwnProperty("buy_bt"))
            {
               addWidget(this.m_skipBt = new FarmAnimatedCashButton(this.m_candyReadyMc["buy_bt"],"Skip Wait",STATION_SKIP_COST.toString(),this.onClickSkipButton));
               this.m_skipBt.visible = false;
            }
            if(this.m_candyReadyMc.hasOwnProperty("candy_ready_icon_mc"))
            {
               addWidget(this.m_candyReadyIcon = new FarmIcon(this.m_candyReadyMc["candy_ready_icon_mc"]));
               this.m_candyReadyIcon.visible = false;
            }
            if(this.m_candyReadyMc.hasOwnProperty("candy_ready_tf"))
            {
               addWidget(this.m_candyReadyTf = new ZwTextField(this.m_candyReadyMc["candy_ready_tf"]));
               this.m_candyReadyTf.visible = false;
            }
            if(this.m_candyReadyMc.hasOwnProperty("candy_ready_bt"))
            {
               addWidget(this.m_candyReadyBT = new FarmAnimatedTextButton(this.m_candyReadyMc["candy_ready_bt"],"Collect",this.onCollect));
               this.m_candyReadyBT.visible = false;
            }
         }
         if(m_element.hasOwnProperty("candy_try_mc"))
         {
            this.m_candyTryMc = m_element["candy_try_mc"] as MovieClip;
            this.m_candyTryMc.visible = false;
            if(this.m_candyTryMc.hasOwnProperty("candy_try_icon_mc"))
            {
               addWidget(this.m_candyReadyTryIcon = new FarmIcon(this.m_candyTryMc["candy_try_icon_mc"]));
               this.m_candyReadyTryIcon.visible = false;
            }
            if(this.m_candyTryMc.hasOwnProperty("new_recipes_tf"))
            {
               addWidget(this.m_candyRcipesTf = new ZwTextField(this.m_candyTryMc["new_recipes_tf"],"Make special treats here"));
               this.m_candyRcipesTf.visible = false;
            }
            if(this.m_candyTryMc.hasOwnProperty("recipe_book_bt"))
            {
               addWidget(this.m_recipeBookBt = new FarmAnimatedTextButton(this.m_candyTryMc["recipe_book_bt"],"Book",this.onClickSpecialCandyBt));
               this.m_recipeBookBt.visible = false;
            }
         }
      }
      
      override public function populate(data:Object) : void
      {
         var stationTimer:Number = NaN;
         var timeLeft:int = 0;
         this.m_candyReadyMc.visible = false;
         this.m_candyTryMc.visible = false;
         this.m_candyReadyIcon.visible = false;
         this.m_specialCandyName = data["specialCandyName"];
         this.m_stationId = data["stationId"];
         this.m_stationBusy = data["stationBusy"];
         if(this.m_stationBusy == 0)
         {
            this.m_candyTryMc.visible = true;
            this.m_candyRcipesTf.visible = true;
            this.m_recipeBookBt.visible = true;
         }
         else if(this.m_stationBusy == 1)
         {
            this.m_candyReadyMc.visible = true;
            stationTimer = Number(data["stationTimer"]);
            timeLeft = this.manager.getStationMakingTimerLeft(stationTimer);
            if(!this.manager.isSpecialCandyVisited(this.m_specialCandyName))
            {
               this.setIconVisible(data);
            }
            if(timeLeft <= 0)
            {
               this.m_candyReadyBT.visible = true;
            }
            else
            {
               this.m_candyReadyTf.text = "Time left " + timeLeft + " minutes";
               this.m_candyReadyTf.visible = true;
               this.m_skipBt.visible = true;
            }
         }
         else if(this.m_stationBusy == 2)
         {
            this.m_candyTryMc.visible = true;
            this.m_recipeBookBt.visible = true;
            this.m_recipeBookBt.text = "Make";
            this.m_recipeBookBt.enabled = false;
            this.m_candyRcipesTf.visible = true;
            if(this.manager.getBasicCandyCountByName(data["base"]) >= 1 && this.manager.getBasicCandyCountByName(data["coat"]) >= 1)
            {
               this.m_recipeBookBt.enabled = true;
            }
            this.setIconVisible(data);
         }
      }
      
      public function setIconVisible(data:Object) : void
      {
         this.m_candyReadyIcon.loadIcon(data["specialCandyUrl"]);
         this.m_candyReadyIcon.setIconSize(50,50);
         this.m_candyReadyIcon.visible = true;
         this.m_candyReadyIcon.attachTooltip(new FarmTextTooltip(data["specialCandyName"]));
      }
      
      public function getFormattedTimeLeft(timeLeft:Number) : String
      {
         var minutes:int = 0;
         var seconds:int = 0;
         var resultMin:String = "";
         var resultSec:String = "";
         var result:String = "";
         if(timeLeft < 0)
         {
            timeLeft = 0;
            return "00:00";
         }
         var timeLeftArray:Array = FarmGameUtil.parseTimeLeft(timeLeft);
         if(Boolean(timeLeftArray) && timeLeftArray.length > 3)
         {
            minutes = int(timeLeftArray[2]);
            seconds = int(timeLeftArray[3]);
            resultMin = "0" + minutes.toString();
            if(seconds < 10)
            {
               resultSec = "0" + seconds.toString();
            }
            else
            {
               resultSec = seconds.toString();
            }
         }
         return resultMin + ":" + resultSec;
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
         this.manager.onCollectSpecialCandy(this.m_specialCandyName,this.m_stationId);
      }
      
      public function onClickSpecialCandyBt(event:Event) : void
      {
         if(this.m_stationBusy == 0)
         {
            this.manager.openCandyConversionWindow();
         }
         else
         {
            this.manager.makeSpecialCandy(this.m_specialCandyName,this.m_stationId,"","");
         }
      }
      
      private function get manager() : CanadaInnovationManager
      {
         return CanadaInnovationManager.getInstance(this.FEATURE_NAME);
      }
      
      override public function release() : void
      {
         super.release();
      }
   }
}

