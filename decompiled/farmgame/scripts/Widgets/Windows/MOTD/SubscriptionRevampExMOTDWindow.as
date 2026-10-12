package Widgets.Windows.MOTD
{
   import Classes.Constants.Experiments;
   import Classes.util.ZLocUtils;
   import Managers.FarmStatsManager;
   import Managers.SubscriptionsManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.TextFields.FarmTextField;
   import flash.events.MouseEvent;
   
   public class SubscriptionRevampExMOTDWindow extends GenericSingleButtonWidgetMOTD
   {
      
      private var m_variant:int = 0;
      
      private const ASSET_URL1:String = "assets/dialogs/Subscriptions/SubUpgrade2016/FV_SubUpgrade2016_Ex_Generic_MOTD.swf";
      
      private const ASSET_URL2:String = "assets/dialogs/Subscriptions/SubUpgrade2016/FV_SubUpgrade2016_Ex_Generic2_MOTD.swf";
      
      public function SubscriptionRevampExMOTDWindow(displayParams:Object = null)
      {
         if(displayParams == null)
         {
            displayParams["dialog"] = this.ASSET_URL1;
         }
         this.m_variant = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_SUBSCRIPTIONS2016_EXSUB);
         if(this.m_variant == 1)
         {
            displayParams["dialog"] = this.ASSET_URL2;
         }
         super(displayParams);
      }
      
      override protected function postLoadComplete() : void
      {
         var level:int = 0;
         var sublevel:String = null;
         var days:int = 0;
         super.postLoadComplete();
         if(m_window.hasOwnProperty("mainWindow"))
         {
            if(this.m_variant == 1)
            {
               FarmStatsManager.count("MOTD","impressions","MOTD_subs_strkrest_stage1_b");
            }
            else
            {
               FarmStatsManager.count("MOTD","impressions","MOTD_subs_strkrest_stage1_a");
            }
            level = SubscriptionsManager.instance.getHeighestSubscriptionLevel();
            sublevel = SubscriptionsManager.instance.getSubscriptionLevelText(level);
            days = SubscriptionsManager.getEADaysRemaining();
            if(m_window.mainWindow.hasOwnProperty("body_tf"))
            {
               addWidget(new FarmTextField(m_window.mainWindow.body_tf,ZLocUtils.t("Dialogs","MOTD_SubscriptionRevampExSub_body",{"level":sublevel})));
            }
            if(m_window.mainWindow.hasOwnProperty("body1_tf"))
            {
               if(days >= 1)
               {
                  addWidget(new FarmTextField(m_window.mainWindow.body1_tf,ZLocUtils.t("Dialogs","MOTD_SubscriptionRevampExSub_body1",{"days":days})));
               }
               else if(days == 0)
               {
                  addWidget(new FarmTextField(m_window.mainWindow.body1_tf,ZLocUtils.t("Dialogs","MOTD_SubscriptionRevampExSub_body2")));
               }
            }
            if(m_window.mainWindow.hasOwnProperty("subtitle_tf"))
            {
               addWidget(new FarmTextField(m_window.mainWindow.subtitle_tf,ZLocUtils.t("Dialogs","MOTD_SubscriptionRevampEx_Sub_subtitle")));
            }
            if(m_window.mainWindow.hasOwnProperty("titletier_tf"))
            {
               addWidget(new FarmTextField(m_window.mainWindow.titletier_tf,ZLocUtils.t("Dialogs","MOTD_SubscriptionRevampEx_Sub_titletier",{"tier":sublevel})));
            }
            if(this.m_variant == 1 && Boolean(m_window.mainWindow.hasOwnProperty("accept_bt")))
            {
               if(m_accept_bt)
               {
                  m_accept_bt.text = ZLocUtils.t("Dialogs","MOTD_SubscriptionRevampExSub_button1");
               }
               else
               {
                  m_accept_bt = addWidget(new FarmAnimatedTextButton(m_window.mainWindow.accept_bt,ZLocUtils.t("Dialogs","MOTD_SubscriptionRevampExSub_button1"))) as FarmAnimatedTextButton;
               }
            }
         }
      }
      
      override protected function onAccept(event:MouseEvent) : void
      {
         if(this.m_variant == 1)
         {
            FarmStatsManager.count("MOTD","click","MOTD_subs_strkrest_stage1_b");
         }
         else
         {
            FarmStatsManager.count("MOTD","click","MOTD_subs_strkrest_stage1_a");
         }
         super.onAccept(event);
         SubscriptionRevampExSignUpWindow.display();
      }
   }
}

