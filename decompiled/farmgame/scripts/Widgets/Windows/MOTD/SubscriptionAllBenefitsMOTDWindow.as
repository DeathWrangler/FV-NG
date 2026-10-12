package Widgets.Windows.MOTD
{
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Managers.FarmStatsManager;
   import Managers.SubscriptionsManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.TextFields.FarmTextField;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   
   public class SubscriptionAllBenefitsMOTDWindow extends GenericSingleButtonWidgetMOTD
   {
      
      public function SubscriptionAllBenefitsMOTDWindow(displayParams:Object = null)
      {
         if(!displayParams)
         {
            displayParams = new Object();
            if(this.show2019RevampMOTD() && !SubscriptionsManager.isRevampTrialActive())
            {
               displayParams["dialog"] = "assets/dialogs/Subscriptions/SubUpgrade2019v2/FV_SubUpgrade2019_Ex_Generic_MOTD.swf";
            }
            else
            {
               displayParams["dialog"] = "assets/dialogs/Subscriptions/SubUpgrade2016/FV_SubUpgrade2016_AllBenefits_MOTD.swf";
            }
         }
         super(displayParams);
         if(!m_currentMOTD)
         {
            m_currentMOTD = new Object();
            m_currentMOTD["buttonText"] = "Dialogs:MOTD_VIP_ALL_BENEFITS_2016_ButtonText";
         }
      }
      
      public function show2019RevampMOTD() : Boolean
      {
         var endTime:Number = NaN;
         var startTime:Number = NaN;
         var result:Boolean = false;
         var now:Number = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
         endTime = FarmGameUtil.synchronizedDateTimeToNumber("12/06/2019") / FarmGameUtil.NUM_MSECS_IN_SECOND;
         startTime = FarmGameUtil.synchronizedDateTimeToNumber("11/08/2019") / FarmGameUtil.NUM_MSECS_IN_SECOND;
         if(now - startTime > 0 && now - endTime < 0)
         {
            result = true;
         }
         return result;
      }
      
      public function getHeighestSubscriptionLevel() : int
      {
         var result:int = 0;
         var streak:int = SubscriptionsManager.instance.getHeighestStreak();
         streak += 3;
         if(streak >= SubscriptionsManager.STREAK_LEVEL_DIAMOND)
         {
            result = SubscriptionsManager.LEVEL_DIAMOND;
         }
         else if(streak >= SubscriptionsManager.STREAK_LEVEL_RUBY)
         {
            result = SubscriptionsManager.LEVEL_RUBY;
         }
         else if(streak >= SubscriptionsManager.STREAK_LEVEL_GOLD)
         {
            result = SubscriptionsManager.LEVEL_GOLD;
         }
         else if(streak >= SubscriptionsManager.STREAK_LEVEL_SILVER)
         {
            result = SubscriptionsManager.LEVEL_SILVER;
         }
         else if(streak >= SubscriptionsManager.STREAK_LEVEL_BRONZE)
         {
            result = SubscriptionsManager.LEVEL_BRONZE;
         }
         else
         {
            result = SubscriptionsManager.LEVEL_INACTIVE;
         }
         return result;
      }
      
      override protected function postLoadComplete() : void
      {
         var benefits:MovieClip = null;
         super.postLoadComplete();
         var level:int = this.getHeighestSubscriptionLevel();
         var sublevel:String = SubscriptionsManager.instance.getSubscriptionLevelText(level);
         if(m_window["mainWindow"])
         {
            if(m_window.mainWindow["title_tf"])
            {
               if(!SubscriptionsManager.isRevampTrialActive())
               {
                  if(this.show2019RevampMOTD())
                  {
                     addWidget(new FarmTextField(m_window.mainWindow["title_tf"],"We Miss You!"));
                  }
                  else
                  {
                     addWidget(new FarmTextField(m_window.mainWindow["title_tf"],ZLocUtils.t_pk("Dialogs:MOTD_VIP_ALL_BENEFITS_2016_STANDARD_Title")));
                  }
               }
               else
               {
                  addWidget(new FarmTextField(m_window.mainWindow["title_tf"],ZLocUtils.t_pk("Dialogs:MOTD_VIP_ALL_BENEFITS_2016_Title")));
               }
            }
            if(m_window.mainWindow["subtitle_tf"])
            {
               if(this.show2019RevampMOTD())
               {
                  addWidget(new FarmTextField(m_window.mainWindow.subtitle_tf,ZLocUtils.t("Dialogs","SubscriptionRevampExSignup_Subtitle",{"sublevel":sublevel})));
               }
               else
               {
                  addWidget(new FarmTextField(m_window.mainWindow["subtitle_tf"],ZLocUtils.t_pk("Dialogs:MOTD_VIP_ALL_BENEFITS_2016_Subtitle")));
               }
            }
            if(m_window.mainWindow["body_tf"])
            {
               if(!SubscriptionsManager.isRevampTrialActive())
               {
                  if(this.show2019RevampMOTD())
                  {
                     addWidget(new FarmTextField(m_window.mainWindow.body_tf,ZLocUtils.t("Dialogs","SubscriptionRevampExSignup_body",{"sublevel":sublevel})));
                  }
                  else
                  {
                     addWidget(new FarmTextField(m_window.mainWindow["body_tf"],ZLocUtils.t_pk("Dialogs:MOTD_VIP_ALL_BENEFITS_2016_STANDARD_Npc1")));
                  }
               }
               else
               {
                  addWidget(new FarmTextField(m_window.mainWindow["body_tf"],ZLocUtils.t_pk("Dialogs:MOTD_VIP_ALL_BENEFITS_2016_Npc1")));
               }
            }
            if(m_window.mainWindow["body1_tf"])
            {
               addWidget(new FarmTextField(m_window.mainWindow["body1_tf"],ZLocUtils.t_pk("Dialogs:MOTD_VIP_ALL_BENEFITS_2016_Npc2")));
            }
            if(SubscriptionsManager.isRevampTrialActive())
            {
               (getWidget(m_window.mainWindow.accept_bt) as FarmAnimatedTextButton).text = ZLocUtils.t_pk("Dialogs:MOTD_VIP_ALL_BENEFITS_2016_Trial_ButtonText");
            }
            else if(this.show2019RevampMOTD())
            {
               (getWidget(m_window.mainWindow.accept_bt) as FarmAnimatedTextButton).text = "I want in!";
            }
            if(this.show2019RevampMOTD())
            {
               if(m_window.mainWindow["benefits_mc"])
               {
                  benefits = m_window.mainWindow.benefits_mc as MovieClip;
                  benefits.gotoAndStop(level);
               }
            }
         }
         if(SubscriptionsManager.isRevampTrialActive())
         {
            FarmStatsManager.count("MOTD","impressions","MOTD_subs_trialv2_stage2");
         }
         else
         {
            FarmStatsManager.count("MOTD","impressions","MOTD_subs_standard_signup");
         }
      }
      
      override protected function onAccept(event:MouseEvent) : void
      {
         this.close();
         if(SubscriptionsManager.isRevampTrialActive())
         {
            FarmStatsManager.count("MOTD","click","MOTD_subs_trialv2_stage2");
         }
         else
         {
            FarmStatsManager.count("MOTD","click","MOTD_subs_standard_signup");
         }
         if(SubscriptionsManager.instance.isExsubscriber())
         {
            SubscriptionsManager.triggerSignUpFlow("sub_revamp");
         }
         else
         {
            SubscriptionsManager.triggerSignUpFlow("SubscriptionAllBenefitsMOTDWindow");
         }
      }
   }
}

