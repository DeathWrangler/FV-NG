package Widgets.Windows.MOTD
{
   import Classes.util.ZLocUtils;
   import Events.SubscriptionsEvent;
   import Managers.FarmStatsManager;
   import Managers.SubscriptionsManager;
   import Widgets.TextFields.FarmTextField;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   
   public class SubscriptionRevampSubscirbersMOTDWindow extends GenericSingleButtonWidgetMOTD
   {
      
      public function SubscriptionRevampSubscirbersMOTDWindow(displayParams:Object = null)
      {
         super(displayParams);
      }
      
      override protected function postLoadComplete() : void
      {
         var level:int = 0;
         var benefits:MovieClip = null;
         super.postLoadComplete();
         if(m_window.hasOwnProperty("mainWindow"))
         {
            FarmStatsManager.count("MOTD","impressions","MOTD_subs_existing");
            if(m_window.mainWindow["subtitle_tf"])
            {
               addWidget(new FarmTextField(m_window.mainWindow.subtitle_tf,ZLocUtils.t("Dialogs","MOTD_SubscriptionRevampSub_subtitle")));
            }
            if(m_window.mainWindow["benefits_mc"])
            {
               level = SubscriptionsManager.instance.getSubscriptionLevel();
               benefits = m_window.mainWindow.benefits_mc as MovieClip;
               benefits.gotoAndStop(level);
            }
         }
      }
      
      override protected function onAccept(event:MouseEvent) : void
      {
         FarmStatsManager.count("MOTD","click","MOTD_subs_existing");
         SubscriptionsManager.instance.dispatchEvent(new SubscriptionsEvent(SubscriptionsManager.SHOW_BENEFITS_POPUP,{"source":"revamp_generic"}));
         super.onAccept(event);
      }
   }
}

