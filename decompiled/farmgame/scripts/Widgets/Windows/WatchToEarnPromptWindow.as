package Widgets.Windows
{
   import Classes.Constants.StatsTrackingConstants;
   import Classes.util.ZLocUtils;
   import Managers.FarmStatsManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.events.Event;
   
   public class WatchToEarnPromptWindow extends FarmWindow
   {
      
      protected const DIALOG_ASSET:String = "assets/dialogs/FV_earnfarmcash.swf";
      
      protected var m_acceptCallback:Function;
      
      protected var m_declineCallback:Function;
      
      public function WatchToEarnPromptWindow(acceptCallback:Function = null, declineCallback:Function = null)
      {
         this.m_acceptCallback = acceptCallback;
         this.m_declineCallback = declineCallback;
         super(this.DIALOG_ASSET,true,true);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         this.setupButtons();
         this.setupHeaders();
         FarmStatsManager.count(StatsTrackingConstants.DIALOG_STATS_COUNTER,"",StatsTrackingConstants.DIALOG_STATS_VIEW_PHYLUM);
      }
      
      protected function setupButtons() : void
      {
         var watchAdMC:ZwFrame = null;
         if(m_window.watchAd_mc)
         {
            watchAdMC = addWidget(new ZwFrame(m_window.watchAd_mc)) as ZwFrame;
            if(watchAdMC.element.watch_bt)
            {
               watchAdMC.addWidget(new FarmAnimatedTextButton(watchAdMC.element.watch_bt,ZLocUtils.t("Dialogs","WatchAd"),this.onWatchAdClickCallback));
            }
         }
      }
      
      protected function setupHeaders() : void
      {
         if(m_window.header_tf)
         {
            addWidget(new ZwTextField(m_window.header_tf,ZLocUtils.t("Dialogs","EarnFarmCash")));
         }
      }
      
      protected function onWatchAdClickCallback(e:Event) : void
      {
         if(this.m_acceptCallback != null)
         {
            this.m_acceptCallback();
         }
         this.close();
      }
      
      override public function close() : void
      {
         if(this.m_declineCallback != null)
         {
            this.m_declineCallback();
         }
         super.close();
      }
      
      override protected function onClose(event:Event) : void
      {
         FarmStatsManager.count(StatsTrackingConstants.DIALOG_STATS_COUNTER,"",StatsTrackingConstants.DIALOG_STATS_X_CLICK_PHYLUM);
         super.onClose(event);
      }
   }
}

