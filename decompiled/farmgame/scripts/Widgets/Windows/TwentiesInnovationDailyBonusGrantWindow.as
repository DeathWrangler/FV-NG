package Widgets.Windows
{
   import Classes.Constants.WorldsConstants;
   import Classes.Constants.ZLocConstants;
   import Classes.ImageLoader;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Managers.TemplateUIUtility;
   import Managers.TwentiesInnovationManager;
   import Managers.WorldSeasonsManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.ObjectPreviewFrame;
   import Widgets.Icons.FarmIcon;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.geom.Point;
   
   public class TwentiesInnovationDailyBonusGrantWindow extends FarmWindow
   {
      
      private static const OFFSET_OPF_Y:int = -30;
      
      protected var m_featureName:String = null;
      
      private var m_reward:FarmItem = null;
      
      private var m_isWeekly:Boolean = false;
      
      private var m_isLeaderboard:Boolean = false;
      
      private var m_leaderboardRank:Number = 0;
      
      private var m_score:int = 0;
      
      private var m_quantity:int = 0;
      
      private var m_callback:Function = null;
      
      protected var title_tf:ZwTextField = null;
      
      protected var m_zoomingScale:int = 3;
      
      private var m_bgLoader:ImageLoader = null;
      
      private var m_bgIcon:DisplayObject = null;
      
      private var m_gift_mc:MovieClip = new MovieClip();
      
      private var m_weeklyRewardData:Object;
      
      public function TwentiesInnovationDailyBonusGrantWindow(dialogAsset:String, featureName:String, rewardItem:FarmItem = null, isWeekly:Boolean = false, weeklyRewardData:Object = null, buttonCallback:Function = null, dialogBackground:String = null, quantity:int = 1, isleaderboard:Boolean = false, rank:Number = 1, score:int = 0)
      {
         super(dialogAsset);
         this.m_reward = rewardItem;
         this.m_featureName = featureName;
         this.m_callback = buttonCallback;
         this.m_isWeekly = isWeekly;
         this.m_weeklyRewardData = weeklyRewardData;
         this.m_quantity = quantity;
         this.m_isLeaderboard = isleaderboard;
         this.m_leaderboardRank = rank;
         this.m_score = score;
         if(dialogBackground != null)
         {
            this.m_bgLoader = ImageLoader.getInstance(Global.getAssetURL(dialogBackground));
            this.m_bgLoader.getContent(this.onBgLoad);
         }
      }
      
      private function onBgLoad(dispObj:DisplayObject, info:Object = null) : void
      {
         this.m_bgIcon = dispObj;
      }
      
      override protected function postLoadComplete() : void
      {
         var weekData:Object = null;
         var buttonCallback:Function = null;
         var iconUrl:String = null;
         super.postLoadComplete();
         var itemName:String = "";
         var itemCode:String = "";
         var weekNum:int = 0;
         if(this.manager)
         {
            weekData = this.manager.getCurrentWeek();
            weekNum = WorldSeasonsManager.getInstance().isEAUser(WorldsConstants.WORLD_ID_TWENTIES) == true ? int(weekData.count) : int(weekData.count - 1);
         }
         if(this.m_reward != null)
         {
            itemName = this.m_reward.friendlyTitle;
            itemCode = this.m_reward.code;
         }
         if(m_window != null)
         {
            if(m_window.hasOwnProperty("generic_tf"))
            {
               this.title_tf = addWidget(new ZwTextField(m_window["generic_tf"],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "GenericText",{"itemName":itemName}))) as ZwTextField;
               if(TemplateUIUtility.isTemplateUIEnabled(TemplateUIUtility.EXPANSION))
               {
                  TemplateUIUtility.applyExpansionTextColor(m_window.generic_tf);
                  TemplateUIUtility.applyExpansionBevelFilter(m_window.generic_tf);
                  TemplateUIUtility.applyExpansionDropShadowFilter(m_window.generic_tf);
               }
            }
            else if(m_window.hasOwnProperty("title_tf"))
            {
               if(this.m_isWeekly)
               {
                  this.title_tf = addWidget(new ZwTextField(m_window["title_tf"],"Great Work!")) as ZwTextField;
               }
               else if(this.m_isLeaderboard)
               {
                  this.title_tf = addWidget(new ZwTextField(m_window["title_tf"],"Congratulations!")) as ZwTextField;
               }
               else
               {
                  this.title_tf = addWidget(new ZwTextField(m_window["title_tf"],"Party Starter!")) as ZwTextField;
               }
               if(TemplateUIUtility.isTemplateUIEnabled(TemplateUIUtility.EXPANSION))
               {
                  TemplateUIUtility.applyExpansionTextColor(m_window.title_tf);
                  TemplateUIUtility.applyExpansionBevelFilter(m_window.title_tf);
                  TemplateUIUtility.applyExpansionDropShadowFilter(m_window.title_tf);
               }
            }
            if(m_window.hasOwnProperty("subtext1_tf"))
            {
               if(this.m_isWeekly)
               {
                  addWidget(new ZwTextField(m_window["subtext1_tf"],"You got the " + this.m_weeklyRewardData.rating + " rating for" + "\n" + "week " + this.m_weeklyRewardData.week + "!"));
               }
               else if(Boolean(this.m_isLeaderboard && this.m_leaderboardRank) && Boolean(this.m_score > 0) && weekNum > 1)
               {
                  addWidget(new ZwTextField(m_window["subtext1_tf"],"You scored " + this.m_score + " and attained Rank " + this.m_leaderboardRank + " in Week " + (weekNum - 1) + "\'s Leaderboard"));
               }
               else
               {
                  addWidget(new ZwTextField(m_window["subtext1_tf"],"You provided Maggie with all the party supplies today!"));
               }
               if(TemplateUIUtility.isTemplateUIEnabled(TemplateUIUtility.EXPANSION))
               {
                  TemplateUIUtility.applyExpansionSubTextColor(m_window.subtext1_tf);
               }
            }
            if(m_window.hasOwnProperty("subtext2_tf"))
            {
               if(this.m_isWeekly)
               {
                  if(this.m_quantity > 1)
                  {
                     addWidget(new ZwTextField(m_window["subtext2_tf"],"You earned " + this.m_quantity.toString() + itemName + ". Keep playing for more rewards!"));
                  }
                  else
                  {
                     addWidget(new ZwTextField(m_window["subtext2_tf"],"You earned a " + itemName + ". Keep playing for more rewards!"));
                  }
               }
               else if(this.m_isLeaderboard && this.m_leaderboardRank < 4)
               {
                  addWidget(new ZwTextField(m_window["subtext2_tf"],"You got these amazing rewards! Find them in your gift box!"));
               }
               else
               {
                  addWidget(new ZwTextField(m_window["subtext2_tf"],"You won a " + itemName + " !"));
               }
               if(TemplateUIUtility.isTemplateUIEnabled(TemplateUIUtility.EXPANSION))
               {
                  TemplateUIUtility.applyExpansionGlowFilter(m_window.subtext2_tf);
               }
            }
            if(m_window.hasOwnProperty("giftbox_mc"))
            {
               this.m_gift_mc = m_window.giftbox_mc;
               this.m_gift_mc.visible = true;
            }
            buttonCallback = new Function();
            if(m_window.hasOwnProperty("accept_bt"))
            {
               buttonCallback = this.onClose;
               if(this.m_callback != null)
               {
                  buttonCallback = this.m_callback;
               }
               addWidget(new FarmAnimatedTextButton(m_window["accept_bt"],"Awesome!",buttonCallback),true);
            }
            if(m_window.hasOwnProperty("icon_mc"))
            {
               iconUrl = this.m_reward.getImageByName(FarmItem.ICON_200);
               if(iconUrl == null)
               {
                  iconUrl = this.m_reward.getImageByName(FarmItem.ICON_FEED);
                  if(iconUrl == null)
                  {
                     iconUrl = this.m_reward.iconUrl;
                  }
               }
               addWidget(new FarmIcon(m_window["icon_mc"],iconUrl));
            }
            else if(m_window.hasOwnProperty("opf_mc"))
            {
               this.addWidget(new ObjectPreviewFrame(m_window.opf_mc,this.m_reward,null,[this.m_zoomingScale],null,"","",null,new Point(0,OFFSET_OPF_Y)));
            }
            else if(m_window.hasOwnProperty("reward_mc"))
            {
               iconUrl = this.m_reward.getImageByName(FarmItem.ICON_200);
               if(iconUrl == null)
               {
                  iconUrl = this.m_reward.getImageByName(FarmItem.ICON_FEED);
               }
               addWidget(new FarmIcon(m_window["reward_mc"],iconUrl));
            }
            if(Boolean(m_window.mc_RewardDialog) && Boolean(this.m_bgIcon))
            {
               m_window.addChildAt(this.m_bgIcon,m_window.getChildIndex(m_window.mc_RewardDialog));
            }
         }
         if(this.manager.mainWindow)
         {
            this.manager.incrementActivePopupCount();
            this.manager.mainWindow.tintWindow();
            this.manager.mainWindow.enableInput = false;
         }
      }
      
      private function get manager() : TwentiesInnovationManager
      {
         return TwentiesInnovationManager.getInstance();
      }
      
      override protected function onLoadComplete(event:Event) : void
      {
         super.onLoadComplete(event);
         if(m_closeButton)
         {
            m_closeButton.visible = false;
         }
      }
      
      override protected function onClose(event:Event) : void
      {
         this.manager.decrementActivePopupCount();
         if(this.manager.mainWindow)
         {
            if(this.manager.canUntintMainWindow())
            {
               this.manager.mainWindow.untintWindow();
               this.manager.mainWindow.enableInput = true;
            }
         }
         super.onClose(event);
      }
   }
}

