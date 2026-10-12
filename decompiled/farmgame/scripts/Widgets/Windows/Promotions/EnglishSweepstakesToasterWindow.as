package Widgets.Windows.Promotions
{
   import Classes.util.ZLocUtils;
   import Display.Promo.EnglishSweepstakesDialog;
   import Managers.EnglishSweepstakesPromoManager;
   import Managers.FarmStatsManager;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Windows.AutoCloseToasterWindow;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   
   public class EnglishSweepstakesToasterWindow extends AutoCloseToasterWindow
   {
      
      public static const QUEST_FINISHED:String = "ecsweeps_toaster_questFinished";
      
      public static const DOOBER_HARVESTED:String = "ecsweeps_toaster_dooberHarvested";
      
      protected static const DEFAULT_TIME_TO_LIVE:Number = 10000;
      
      protected static const EXTENDED_TIME_TO_LIVE:Number = 45000;
      
      protected static const POPUP_ICON_WIDTH:Number = 50;
      
      protected static const POPUP_ICON_HEIGHT:Number = 50;
      
      private var m_toasterType:String;
      
      protected var m_dooberIcon:ZwFrame;
      
      public function EnglishSweepstakesToasterWindow(toasterType:String = "ecsweeps_toaster_dooberHarvested")
      {
         super("assets/dialogs/FV_BannerAd_England_sweepstakes.swf");
         this.m_toasterType = toasterType;
         duration = this.m_toasterType == DOOBER_HARVESTED ? DEFAULT_TIME_TO_LIVE : EXTENDED_TIME_TO_LIVE;
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         addWidget(new ZwTextField(m_window.generic_tf,ZLocUtils.t("Dialogs","EnglishSweepstakes_JustCongratulations")));
         if(this.m_toasterType == EnglishSweepstakesToasterWindow.QUEST_FINISHED)
         {
            addWidget(new ZwTextField(m_window.generic_desc_tf,ZLocUtils.t("Dialogs","EnglishSweepstakes_QuestFinished_Toaster"),true));
            FarmStatsManager.count("englandsweeps","questcomplete","toaster","display");
         }
         else
         {
            addWidget(new ZwTextField(m_window.generic_desc_tf,ZLocUtils.t("Dialogs","EnglishSweepstakes_DooberHarvest_Toaster"),true));
            FarmStatsManager.count("englandsweeps","tripdoober","toaster","display");
         }
         addWidget(new ZwTextField(m_window.generic_desc1_tf,ZLocUtils.t("FarmVille","EnglandSweeps_Rules",{"url":EnglishSweepstakesDialog.RULES_URL}),true),true);
         var popupIcon:FarmIcon = new FarmIcon(m_window.icon_mc);
         popupIcon.loadIcon("assets/misc/doober_sweeps.png");
         popupIcon.setIconSize(POPUP_ICON_WIDTH,POPUP_ICON_HEIGHT);
         addWidget(popupIcon);
         addWidget(new ZwWidget(m_window.hitbox_mc));
         (m_window.hitbox_mc as MovieClip).buttonMode = true;
         (m_window.hitbox_mc as MovieClip).addEventListener(MouseEvent.CLICK,this.onClick);
         m_window.close_bt.addEventListener(MouseEvent.CLICK,onClose);
      }
      
      protected function onClick(event:MouseEvent) : void
      {
         if(event)
         {
            event.stopPropagation();
         }
         if(this.m_toasterType == EnglishSweepstakesToasterWindow.QUEST_FINISHED)
         {
            FarmStatsManager.count("englandsweeps","questcomplete","toaster","click");
         }
         else
         {
            FarmStatsManager.count("englandsweeps","tripdoober","toaster","click");
         }
         EnglishSweepstakesPromoManager.showDialog();
         close();
      }
      
      override protected function release() : void
      {
         (m_window.hitbox_mc as MovieClip).removeEventListener(MouseEvent.CLICK,this.onClick);
         super.release();
      }
   }
}

