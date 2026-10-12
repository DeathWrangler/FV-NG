package Widgets.Windows
{
   import Classes.util.ZLocUtils;
   import Managers.FarmStatsManager;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.events.Event;
   
   public final class HelpingHandsWindow extends FarmWindow
   {
      
      public static var ASSET_PATH:String = "assets/dialogs/FV_HiredHand.swf";
      
      public static var EXPERIMENT_NAME:String = "fv_hired_hands_heat_test";
      
      public static var SEEN_FLAG_NAME:String = "HiredHandsHeatTest_seenflag";
      
      private var m_xmark:ZwBaseWidget = null;
      
      private var m_doNotShowAgain:Boolean = false;
      
      public function HelpingHandsWindow()
      {
         super(ASSET_PATH);
      }
      
      override protected function postLoadComplete() : void
      {
         var comingSoonMc:ZwFrame = null;
         var mainMc:ZwFrame = null;
         var replantTf:ZwTextField = null;
         super.postLoadComplete();
         var expVariant:int = Global.experimentManager.getExperimentVariant(EXPERIMENT_NAME);
         if(m_window.title_tf)
         {
            addWidget(new ZwTextField(m_window.title_tf,ZLocUtils.t("Dialogs","HiredHands_title")));
         }
         if(m_window.comingSoon_mc)
         {
            addWidget(new ZwFrame(m_window.comingSoon_mc)).visible = false;
            comingSoonMc = getWidget(m_window.comingSoon_mc) as ZwFrame;
            if(comingSoonMc.element.coming_tf)
            {
               comingSoonMc.addWidget(new ZwTextField(comingSoonMc.element.coming_tf,ZLocUtils.t("Dialogs","ComingSoon")));
            }
            if(comingSoonMc.element.generic_tf)
            {
               comingSoonMc.addWidget(new ZwTextField(comingSoonMc.element.generic_tf,ZLocUtils.t("Dialogs","HiredHands_comingSoonSub")));
            }
         }
         if(m_window.main_mc)
         {
            addWidget(new ZwFrame(m_window.main_mc));
            mainMc = getWidget(m_window.main_mc) as ZwFrame;
            if(mainMc.element.subtitle_tf)
            {
               mainMc.addWidget(new ZwTextField(mainMc.element.subtitle_tf,ZLocUtils.t("Dialogs","HiredHands_mainSub")));
            }
            if(mainMc.element.replant_tf)
            {
               replantTf = mainMc.addWidget(new ZwTextField(mainMc.element.replant_tf,this.determineReplantText(expVariant))) as ZwTextField;
            }
            if(mainMc.element.wages_tf)
            {
               mainMc.addWidget(new ZwTextField(mainMc.element.wages_tf,ZLocUtils.t("Dialogs","HiredHands_wages",{"wages":this.determinePrice(expVariant).toString()})));
            }
            if(mainMc.element.perField_tf)
            {
               mainMc.addWidget(new ZwTextField(mainMc.element.perField_tf,ZLocUtils.t("Dialogs","HiredHands_perfield")));
            }
            if(mainMc.element.doNotShow_tf)
            {
               mainMc.addWidget(new ZwTextField(mainMc.element.doNotShow_tf,ZLocUtils.t("Dialogs","HiredHands_doNotShowAgain")));
            }
            if(mainMc.element.buy_mc)
            {
               mainMc.addWidget(new FarmAnimatedTextButton(mainMc.element.buy_mc,ZLocUtils.t("Dialogs","Purchase"),this.onAcceptClick));
            }
            if(Boolean(mainMc.element.xmark_mc) && Boolean(mainMc.element.xbox_mc))
            {
               this.m_xmark = mainMc.addWidget(new ZwBaseWidget(mainMc.element.xmark_mc)) as ZwBaseWidget;
               this.m_xmark.visible = false;
               mainMc.addWidget(new FarmAnimatedButton(mainMc.element.xbox_mc,this.onXboxClick));
            }
         }
      }
      
      protected function determineReplantText(expVariant:int) : String
      {
         var text:String = "";
         switch(expVariant)
         {
            case 1:
               text = ZLocUtils.t("Dialogs","HiredHands_replant_1");
               break;
            case 3:
               text = ZLocUtils.t("Dialogs","HiredHands_replant_3");
               break;
            default:
               text = ZLocUtils.t("Dialogs","HiredHands_replant");
         }
         return text;
      }
      
      protected function determinePrice(expVariant:int) : int
      {
         var wagesInt:int = 10;
         switch(expVariant)
         {
            case 4:
               wagesInt = 5;
               break;
            case 5:
               wagesInt = 10;
               break;
            case 6:
               wagesInt = 15;
               break;
            case 7:
               wagesInt = 20;
               break;
            case 8:
               wagesInt = 25;
         }
         return wagesInt;
      }
      
      protected function onXboxClick(event:Event) : void
      {
         this.m_xmark.visible = !this.m_xmark.visible;
         this.m_doNotShowAgain = this.m_xmark.visible;
      }
      
      protected function onAcceptClick(event:Event) : void
      {
         this.switchFrame(getWidget(m_window.comingSoon_mc) as ZwFrame);
         FarmStatsManager.count("hired_hands","dialog_views","clicks_purchase");
      }
      
      override protected function onClose(event:Event) : void
      {
         if(this.m_doNotShowAgain)
         {
            FarmStatsManager.count("hired_hands","opt_out");
         }
         if(getWidget(m_window.comingSoon_mc).visible == false)
         {
            FarmStatsManager.count("hired_hands","dialog_views","clicks_close");
         }
         Global.player.setSeenFlag(SEEN_FLAG_NAME);
         super.onClose(event);
      }
      
      protected function switchFrame(visibleFrame:ZwFrame) : void
      {
         var frame:ZwFrame = null;
         var switchableFrames:Array = [getWidget(m_window.comingSoon_mc),getWidget(m_window.main_mc)];
         for each(frame in switchableFrames)
         {
            frame.visible = false;
         }
         visibleFrame.visible = true;
      }
   }
}

