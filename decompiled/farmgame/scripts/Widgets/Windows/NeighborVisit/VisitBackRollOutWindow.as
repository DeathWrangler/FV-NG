package Widgets.Windows.NeighborVisit
{
   import Classes.util.ZLocUtils;
   import Managers.FarmStatsManager;
   import Managers.MFSRequestManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Buttons.FarmButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.external.ExternalInterface;
   import flash.utils.Timer;
   
   public class VisitBackRollOutWindow extends AbstractRolloutWindow
   {
      
      private static const VISIT_BACK_PERSIST_TIME:Number = 15000;
      
      private static const GIFT_NAME:String = "socialplumbingmysterygift";
      
      private static const COUNTER_NAME:String = "neighbor_visit";
      
      private static const NEIGHBOR_CLICK_SUB_COUNTER:String = "avatar_neighbor_click";
      
      private static const VARAINT_VISIT_ONLY:int = 2;
      
      private static const VARIANT_GIFT_ONLY:int = 3;
      
      private static const VARIANT_VISIT_AND_GIFT:int = 4;
      
      private static const VARIANT_GIFT_THEN_VISIT:int = 5;
      
      private static const VARIANT_VISIT_BACK:int = 4;
      
      private var m_visitBackVaraint:int;
      
      private var m_friendUID:String;
      
      private var m_friendName:String;
      
      private var m_giftButtonToSwap:FarmAnimatedTextButton;
      
      private var m_visitBackTimer:Timer;
      
      public function VisitBackRollOutWindow(friendUid:String, friendName:String)
      {
         super("assets/dialogs/FV_VisitBack_rollOut.swf");
         this.m_friendUID = friendUid;
         this.m_visitBackVaraint = VARIANT_VISIT_BACK;
         this.m_friendName = friendName;
      }
      
      override public function tweenIn() : void
      {
         super.tweenIn();
         this.m_visitBackTimer = new Timer(VISIT_BACK_PERSIST_TIME);
         this.m_visitBackTimer.addEventListener(TimerEvent.TIMER,this.onVisitBackTimeUp);
         this.m_visitBackTimer.start();
      }
      
      override protected function postLoadComplete() : void
      {
         var localizedText:String = null;
         super.postLoadComplete();
         addWidget(new ZwFrame(m_window.rollOut_mc));
         addWidget(new FarmButton(m_window.rollOut_mc.close_bt,this.onClose));
         localizedText = ZLocUtils.t("Dialogs","VisitBackRolloutText");
         addWidget(new ZwTextField(m_window.rollOut_mc.generic_tf,localizedText));
         if(this.m_visitBackVaraint == VARAINT_VISIT_ONLY)
         {
            localizedText = ZLocUtils.t("Dialogs","VisitBackVisitButtonBig");
            addWidget(new FarmAnimatedTextButton(m_window.rollOut_mc.visitLrg_bt,localizedText,this.onVisitClick));
         }
         else if(this.m_visitBackVaraint == VARIANT_GIFT_ONLY)
         {
            localizedText = ZLocUtils.t("Dialogs","VisitBackGiftButtonBig");
            addWidget(new FarmAnimatedTextButton(m_window.rollOut_mc.giftLrg_bt,localizedText,this.onGiftClick));
         }
         else if(this.m_visitBackVaraint == VARIANT_VISIT_AND_GIFT)
         {
            localizedText = ZLocUtils.t("Dialogs","VisitBackVisitButtonSmall");
            addWidget(new FarmAnimatedTextButton(m_window.rollOut_mc.visit_bt,localizedText,this.onVisitClick));
            localizedText = ZLocUtils.t("Dialogs","VisitBackGiftButtonSmall");
            addWidget(new FarmAnimatedTextButton(m_window.rollOut_mc.gift_bt,localizedText,this.onGiftClick));
         }
         else if(this.m_visitBackVaraint == VARIANT_GIFT_THEN_VISIT)
         {
            localizedText = ZLocUtils.t("Dialogs","VisitBackGiftButtonBig");
            this.m_giftButtonToSwap = new FarmAnimatedTextButton(m_window.rollOut_mc.giftLrg_bt,localizedText,this.onGiftClick);
            addWidget(this.m_giftButtonToSwap);
         }
      }
      
      override protected function release() : void
      {
         super.release();
         if(this.m_visitBackTimer)
         {
            this.m_visitBackTimer.stop();
            this.m_visitBackTimer = null;
         }
      }
      
      private function onVisitBackTimeUp(event:TimerEvent) : void
      {
         close();
      }
      
      private function onClose(event:Event) : void
      {
         FarmStatsManager.count(COUNTER_NAME,NEIGHBOR_CLICK_SUB_COUNTER,"close_visit_gift_back");
         close();
      }
      
      private function onGiftClick(event:Event) : void
      {
         var localizedText:String = null;
         FarmStatsManager.count(COUNTER_NAME,NEIGHBOR_CLICK_SUB_COUNTER,"gift_back");
         MFSRequestManager.getInstance().makeSendFreeGiftsRequest(GIFT_NAME,NEIGHBOR_CLICK_SUB_COUNTER,ZLocUtils.t("Gifts","VisitBack_ask_request_text"),this.m_friendUID.toString());
         if(this.m_giftButtonToSwap)
         {
            this.m_visitBackTimer.reset();
            removeWidget(this.m_giftButtonToSwap);
            this.m_giftButtonToSwap = null;
            localizedText = ZLocUtils.t("Dialogs","VisitBackVisitButtonBig");
            addWidget(new FarmAnimatedTextButton(m_window.rollOut_mc.visitLrg_bt,localizedText,this.onVisitClick));
         }
         else
         {
            close();
         }
      }
      
      private function onSendGiftClose() : void
      {
         ExternalInterface.addCallback("onCloseOverlay",null);
         this.m_visitBackTimer.start();
      }
      
      private function onVisitClick(event:Event) : void
      {
         FarmStatsManager.count(COUNTER_NAME,NEIGHBOR_CLICK_SUB_COUNTER,"visit_back");
         Global.worldManager.visitNeighbor(this.m_friendUID.toString());
         close();
      }
   }
}

