package Widgets.Windows
{
   import Cache.Classes.ZCacheUtil;
   import Classes.Constants.ZLocConstants;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocFailoverEntry;
   import Classes.util.ZLocUtils;
   import Display.TutorialUI;
   import Engine.Managers.StatsManager;
   import Engine.Managers.TransactionManager;
   import Events.FarmGameWorldEvent;
   import Managers.TemplateUIUtility;
   import Managers.TimedSlotGiveawaysManager;
   import Transactions.TransactionWithCallBack;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Core.Constants.ZwToggleState;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.GenericLeaderboardSlotFrame;
   import Widgets.Frames.TimedGiveawaySlotFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.Menu.FarmTabMenuButton;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class TimedGiveawayWindow extends FarmWindow
   {
      
      private static var s_cachedLeaderboardData:Object;
      
      private static const LEADERBOARD_DATA_KEY_MAP:Array = [VAL_GLOBAL_LEADERBOARD,VAL_NEIGHBOR_LEADERBOARD];
      
      private static const NUM_LEADERBOARD_DATA_KEYS:int = LEADERBOARD_DATA_KEY_MAP.length;
      
      private static const KEY_GLOBAL_LEADERBOARD:int = 0;
      
      private static const KEY_NEIGHBOR_LEADERBOARD:int = 1;
      
      private static const VAL_GLOBAL_LEADERBOARD:String = "globalLeaderboardData";
      
      private static const VAL_NEIGHBOR_LEADERBOARD:String = "neighborleaderboardData";
      
      private var m_featureName:String = "";
      
      private var m_slotFrame:TimedGiveawaySlotFrame = null;
      
      private var m_currentlyVisibleLeaderboardFrame:GenericLeaderboardSlotFrame;
      
      private var m_currentlySelectedTabButton:FarmTabMenuButton;
      
      private var m_leaderboards:Vector.<GenericLeaderboardSlotFrame> = new Vector.<GenericLeaderboardSlotFrame>();
      
      private var m_tabButtons:Vector.<FarmTabMenuButton> = new Vector.<FarmTabMenuButton>();
      
      private var m_buttonToLeaderboardHash:Object = {};
      
      public function TimedGiveawayWindow(featureName:String)
      {
         this.m_featureName = featureName;
         super(TimedSlotGiveawaysManager.getSwfForGiveaway(this.m_featureName));
      }
      
      private static function giveGiftAfterPostInit(featureName:String, event:FarmGameWorldEvent) : void
      {
         if(Global.world.hasEventListener(FarmGameWorldEvent.USER_POST_INIT_COMPLETE))
         {
            Global.world.removeEventListener(FarmGameWorldEvent.USER_POST_INIT_COMPLETE,giveGiftAfterPostInit);
         }
         TimedSlotGiveawaysManager.giveGifts(featureName);
      }
      
      override protected function postLoadComplete() : void
      {
         var description:String = null;
         var genericString:String = null;
         var descriptionString:String = null;
         var image:String = null;
         var giftItem:FarmItem = null;
         var leaderboardFrame:MovieClip = null;
         var mcKey:int = 0;
         var leaderboard:GenericLeaderboardSlotFrame = null;
         var subNav:MovieClip = null;
         var numLeaderboardFrames:int = 0;
         var mcName:String = null;
         var tabButton:FarmTabMenuButton = null;
         var titleColor:String = null;
         var textColor:String = null;
         super.postLoadComplete();
         var dayToShow:String = TimedSlotGiveawaysManager.getCurrentObjectPastDay(this.m_featureName);
         var disabled:Boolean = TimedSlotGiveawaysManager.isDisabled(this.m_featureName);
         var titleTextField:ZwTextField = null;
         var timerTf:ZwTextField = null;
         var timeLeftTf:ZwTextField = null;
         var descriptionTf:ZwTextField = null;
         var totalVotesTf:ZwTextField = null;
         if(m_window.title_tf != null)
         {
            titleTextField = addWidget(new ZwTextField(m_window.title_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "GiveawayTitle"))) as ZwTextField;
         }
         if(m_window.description_tf != null)
         {
            description = this.m_featureName + "GiveawayDescription";
            if(disabled)
            {
               description = this.m_featureName + "GiveawayDescription_Disabled";
            }
            descriptionTf = addWidget(new ZwTextField(m_window.description_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,description))) as ZwTextField;
         }
         if(!disabled)
         {
            if(m_window.timer_tf != null)
            {
               timerTf = addWidget(new ZwTextField(m_window.timer_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "GiveawayTimer",{"hoursBetweenFeedPosts":TimedSlotGiveawaysManager.HOURS_BETWEEN_POSTS}))) as ZwTextField;
            }
            if(m_window.timeLeft_tf != null)
            {
               timeLeftTf = addWidget(new ZwTextField(m_window.timeLeft_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "GiveawayTimeLeft",{"daysLeft":TimedSlotGiveawaysManager.daysUntilDisabled(this.m_featureName)}))) as ZwTextField;
            }
            if(m_window.circle_mc != null)
            {
               addWidget(new ZwBaseWidget(m_window.circle_mc));
            }
         }
         if(m_window.generic_tf != null)
         {
            genericString = ZLocUtils.getFailoverLocString([new ZLocFailoverEntry(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "GiveawayMainText" + dayToShow),new ZLocFailoverEntry(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "GiveawayMainText")]);
            addWidget(new ZwTextField(m_window.generic_tf,genericString));
         }
         if(m_window.generic2_tf != null)
         {
            descriptionString = ZLocUtils.getFailoverLocString([new ZLocFailoverEntry(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "GiveawayDescription" + dayToShow),new ZLocFailoverEntry(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "GiveawayDescription")]);
            addWidget(new ZwTextField(m_window.generic2_tf,descriptionString));
         }
         if(m_window.totalVotes_tf != null)
         {
            totalVotesTf = addWidget(new ZwTextField(m_window.totalVotes_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "GiveawayTotalCredits",{"totalCredits":TimedSlotGiveawaysManager.getTotalCredits(this.m_featureName)}))) as ZwTextField;
         }
         if(m_window.icon_mc != null)
         {
            image = TimedSlotGiveawaysManager.getImageForGiveaway(this.m_featureName);
            addWidget(new FarmIcon(m_window.icon_mc,image));
         }
         if(m_window.whatisthis_mc != null)
         {
            addWidget(new FarmAnimatedButton(m_window.whatisthis_mc,this.showWhatIsThis));
         }
         if(m_window.reward_mc != null)
         {
            addWidget(new ZwBaseWidget(m_window.reward_mc),disabled);
            if(m_window.reward_mc.trophey_mc != null)
            {
               giftItem = Global.farmGameSettingsManager.getFarmItemByName(TimedSlotGiveawaysManager.getLeaderboardGift(this.m_featureName));
               if(giftItem)
               {
                  addWidget(new FarmIcon(m_window.reward_mc.trophey_mc,giftItem.icon),disabled);
               }
            }
         }
         if(!Global.player.postInitFinished)
         {
            Global.world.addEventListener(FarmGameWorldEvent.USER_POST_INIT_COMPLETE,ZCacheUtil.applyPartial(giveGiftAfterPostInit,null,[this.m_featureName]),false,0,true);
         }
         else
         {
            giveGiftAfterPostInit(this.m_featureName,null);
         }
         if(m_window.leaderboardFrame_mc is MovieClip)
         {
            leaderboardFrame = m_window.leaderboardFrame_mc;
            leaderboardFrame.visible = true;
            mcKey = 0;
            while(leaderboardFrame["leaderboard" + mcKey + "_mc"])
            {
               leaderboard = new GenericLeaderboardSlotFrame(leaderboardFrame["leaderboard" + mcKey + "_mc"],null,this.m_featureName,this);
               this.m_leaderboards.push(leaderboard);
               addWidget(leaderboard,false);
               mcKey++;
            }
            if(!s_cachedLeaderboardData && mcKey > 0)
            {
               TransactionManager.addTransaction(new TransactionWithCallBack("TimedGiveawayService.getLeaderboardEntries",this.populateLeaderboard,this.m_featureName));
            }
            if(leaderboardFrame.subNav_mc is MovieClip)
            {
               subNav = leaderboardFrame.subNav_mc;
               numLeaderboardFrames = int(this.m_leaderboards.length);
               mcKey = 0;
               while(Boolean(subNav["tab_" + mcKey + "_bt"]) && mcKey < numLeaderboardFrames)
               {
                  mcName = "tab_" + mcKey + "_bt";
                  tabButton = new FarmTabMenuButton(subNav[mcName],"",this.onTabButtonClicked);
                  this.m_tabButtons.push(tabButton);
                  this.m_buttonToLeaderboardHash[mcName] = {
                     "button":tabButton,
                     "frame":this.m_leaderboards[mcKey]
                  };
                  addWidget(tabButton,false);
                  mcKey++;
               }
               this.onTabButtonClickedHelper(this.m_tabButtons[KEY_GLOBAL_LEADERBOARD],this.m_leaderboards[KEY_GLOBAL_LEADERBOARD]);
               this.onTabButtonClickedHelper(this.m_tabButtons[KEY_NEIGHBOR_LEADERBOARD],this.m_leaderboards[KEY_NEIGHBOR_LEADERBOARD]);
            }
         }
         if(TimedSlotGiveawaysManager.isTemplateUIEnabled(this.m_featureName))
         {
            if(m_window.background_mc != null)
            {
               addWidget(new FarmIcon(m_window.background_mc,TimedSlotGiveawaysManager.getBackground(this.m_featureName)));
            }
            if(m_window.top_mc != null)
            {
               addWidget(new FarmIcon(m_window.top_mc,TimedSlotGiveawaysManager.getTopBackground(this.m_featureName)));
            }
            titleColor = TimedSlotGiveawaysManager.getTitleColor(this.m_featureName);
            if(Boolean(titleTextField) && Boolean(titleColor != null) && titleColor != "")
            {
               TemplateUIUtility.applyTextColor(titleTextField,TemplateUIUtility.FARM_STAND,titleColor);
            }
            textColor = TimedSlotGiveawaysManager.getTextColor(this.m_featureName);
            if(textColor != null && textColor != "")
            {
               if(timerTf)
               {
                  TemplateUIUtility.applyTextColor(timerTf,TemplateUIUtility.FARM_STAND,textColor);
               }
               if(timeLeftTf)
               {
                  TemplateUIUtility.applyTextColor(timeLeftTf,TemplateUIUtility.FARM_STAND,textColor);
               }
               if(descriptionTf)
               {
                  TemplateUIUtility.applyTextColor(descriptionTf,TemplateUIUtility.FARM_STAND,textColor);
               }
               if(totalVotesTf)
               {
                  TemplateUIUtility.applyTextColor(totalVotesTf,TemplateUIUtility.FARM_STAND,textColor);
               }
            }
         }
         if(m_window.hasOwnProperty("slotFrame_mc"))
         {
            this.m_slotFrame = addWidget(new TimedGiveawaySlotFrame(m_window.slotFrame_mc,this)) as TimedGiveawaySlotFrame;
         }
         StatsManager.count("TimedGiveaway",this.m_featureName,"window","impression");
         if(s_cachedLeaderboardData)
         {
            this.populateLeaderboard(s_cachedLeaderboardData);
         }
      }
      
      private function onTabButtonClicked(event:Event) : void
      {
         var buttonFrameObj:Object = this.m_buttonToLeaderboardHash[event.currentTarget.name];
         if(buttonFrameObj)
         {
            this.onTabButtonClickedHelper(buttonFrameObj.button,buttonFrameObj.frame);
         }
      }
      
      private function onTabButtonClickedHelper(tabButton:FarmTabMenuButton, leaderboardFrame:GenericLeaderboardSlotFrame) : void
      {
         if(this.m_currentlySelectedTabButton)
         {
            this.m_currentlySelectedTabButton.setToggleState(ZwToggleState.DESELECTED);
         }
         if(tabButton)
         {
            this.m_currentlySelectedTabButton = tabButton;
            this.m_currentlySelectedTabButton.setToggleState(ZwToggleState.SELECTED);
            this.m_currentlySelectedTabButton.visible = true;
         }
         if(this.m_currentlyVisibleLeaderboardFrame)
         {
            this.m_currentlyVisibleLeaderboardFrame.visible = false;
         }
         if(leaderboardFrame)
         {
            this.m_currentlyVisibleLeaderboardFrame = leaderboardFrame;
            this.m_currentlyVisibleLeaderboardFrame.visible = true;
         }
      }
      
      public function populateLeaderboard(result:Object) : void
      {
         var finished:Boolean = false;
         var winner:Boolean = false;
         var numLeaderboards:int = 0;
         var numTabButtons:int = 0;
         var i:int = 0;
         var leaderboardDataKey:String = null;
         var leaderboardData:Object = null;
         if(result)
         {
            if(!s_cachedLeaderboardData)
            {
               s_cachedLeaderboardData = result;
            }
            finished = TimedSlotGiveawaysManager.isDisabled(this.m_featureName);
            winner = false;
            if(finished)
            {
               winner = this.conditionallyAwardLeaderboarGift(result);
            }
            if(Boolean(this.m_leaderboards) && Boolean(this.m_tabButtons))
            {
               numLeaderboards = int(this.m_leaderboards.length);
               numTabButtons = int(this.m_tabButtons.length);
               i = 0;
               while(i < numLeaderboards && i < numTabButtons && i < NUM_LEADERBOARD_DATA_KEYS)
               {
                  leaderboardDataKey = LEADERBOARD_DATA_KEY_MAP[i];
                  if(result[leaderboardDataKey])
                  {
                     leaderboardData = result[leaderboardDataKey];
                     this.m_leaderboards[i].finishLoading(leaderboardData,finished,winner);
                     if(leaderboardData.buttonText)
                     {
                        this.m_tabButtons[i].text = leaderboardData.buttonText;
                        this.m_tabButtons[i].autoSizeWidth();
                        if(i > 0 && this.m_tabButtons[i - 1].visible)
                        {
                           this.m_tabButtons[i].x = this.m_tabButtons[i - 1].x + this.m_tabButtons[i - 1].width;
                        }
                     }
                  }
                  i++;
               }
            }
         }
      }
      
      private function conditionallyAwardLeaderboarGift(leaderboardData:Object) : Boolean
      {
         var globalLeaderboardData:Object = null;
         var globalLeadersSlotData:Array = null;
         var data:Object = null;
         var winner:Boolean = false;
         if(leaderboardData[VAL_GLOBAL_LEADERBOARD])
         {
            globalLeaderboardData = leaderboardData[VAL_GLOBAL_LEADERBOARD];
            if(globalLeaderboardData.slotData is Array)
            {
               globalLeadersSlotData = globalLeaderboardData.slotData as Array;
               if(globalLeadersSlotData)
               {
                  for each(data in globalLeadersSlotData)
                  {
                     if(Boolean(data.rank) && data.uid == String(Global.player.uid))
                     {
                        TimedSlotGiveawaysManager.awardLeaderboardGift(this.m_featureName,data.rank);
                        winner = true;
                        break;
                     }
                  }
               }
            }
         }
         return winner;
      }
      
      public function getFeatureName() : String
      {
         return this.m_featureName;
      }
      
      private function showWhatIsThis(event:MouseEvent) : void
      {
         TutorialUI.displayBundleTutorialWindow(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName,"assets/dialogs/4d_elements/FV_farmStand/FV_farmstand");
      }
      
      override public function refreshWindow() : void
      {
         super.refreshWindow();
         if(this.m_slotFrame != null)
         {
            this.m_slotFrame.setData(TimedSlotGiveawaysManager.getItemsForGiveaway(this.m_featureName));
         }
      }
      
      override protected function release() : void
      {
         this.m_buttonToLeaderboardHash = null;
         this.m_currentlySelectedTabButton = null;
         this.m_currentlyVisibleLeaderboardFrame = null;
         this.m_featureName = null;
         this.m_leaderboards = null;
         this.m_slotFrame = null;
         this.m_tabButtons = null;
         super.release();
      }
   }
}

