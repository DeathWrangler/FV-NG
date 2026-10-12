package Widgets.Windows
{
   import Classes.ZItem.FarmItem;
   import Managers.JumbleVillaManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class JumbleVillaRewardPopup extends FarmWindowWithTutorial
   {
      
      private static const FEATURE_NAME:String = "JumbleVilla";
      
      private static const FINDER_ICONS_PREFIX:String = "assets/dialogs/Jumblevilla_2020/Findr";
      
      private static const FINDER_ICONS_SUFFIX:String = "_icon_200.png";
      
      private var m_giftbox_mc:MovieClip;
      
      private var m_npc_mc:MovieClip;
      
      private var m_icon_mc:FarmIcon;
      
      private var m_okay_bt:FarmAnimatedTextButton;
      
      private var m_share_bt:FarmAnimatedTextButton;
      
      private var m_title_tf:ZwTextField;
      
      private var m_subtext1_tf:ZwTextField;
      
      private var m_subtext2_tf:ZwTextField;
      
      private var m_txt_tf:ZwTextField;
      
      private var m_rewardName:String;
      
      private var m_isFinderGrant:Boolean;
      
      private var m_FinderLevel:Number;
      
      private var m_isBonusReward:Boolean;
      
      public function JumbleVillaRewardPopup(featureName:String = "JumbleVilla", assetUrl:String = null, rewardName:String = null, isFinderGrant:Boolean = false, finderLevel:Number = -1, isBonusReward:Boolean = false)
      {
         this.m_rewardName = rewardName;
         this.m_isFinderGrant = isFinderGrant;
         this.m_FinderLevel = finderLevel;
         this.m_isBonusReward = isBonusReward;
         super(featureName,assetUrl);
      }
      
      override protected function postLoadComplete() : void
      {
         var feedUrl:String = null;
         var text:String = null;
         var subText1:String = null;
         var rewardItem:FarmItem = null;
         var rewardFriendlyTitle:String = null;
         var subText2:String = null;
         if(m_window)
         {
            if(m_window.hasOwnProperty("giftbox_mc"))
            {
               this.m_giftbox_mc = m_window["giftbox_mc"] as MovieClip;
               this.m_giftbox_mc.visible = !this.m_isFinderGrant;
            }
            if(m_window.hasOwnProperty("icon_mc"))
            {
               addWidget(this.m_icon_mc = new FarmIcon(m_window["icon_mc"]));
               this.m_icon_mc.visible = true;
               if(!this.m_isFinderGrant)
               {
                  feedUrl = this.getRewardFeedURL(this.m_rewardName);
               }
               else if(!this.m_isBonusReward)
               {
                  feedUrl = this.getFinderFeedURL(this.m_FinderLevel);
               }
               else
               {
                  feedUrl = "assets/dialogs/Jumblevilla_2020/friendshangout_icon_200.png";
               }
               this.m_icon_mc.loadIcon(feedUrl);
            }
            if(m_window.hasOwnProperty("npc_mc"))
            {
               this.m_npc_mc = m_window["npc_mc"] as MovieClip;
               this.m_npc_mc.visible = this.m_isFinderGrant;
               if(this.m_npc_mc.hasOwnProperty("txt_tf"))
               {
                  text = "You start with  Level " + String(this.m_FinderLevel + 1) + " Finder!\n" + "\n" + "Harvest Crops and the finder will automatically find lost pieces for you!";
                  addWidget(this.m_txt_tf = new ZwTextField(this.m_npc_mc["txt_tf"],text));
                  this.m_txt_tf.visible = this.m_isFinderGrant;
               }
            }
            if(m_window.hasOwnProperty("okay_bt"))
            {
               addWidget(this.m_okay_bt = new FarmAnimatedTextButton(m_window["okay_bt"],"Awesome!",this.onClose));
               if(!this.m_isFinderGrant)
               {
                  this.m_okay_bt.text = "Thank you!";
               }
               this.m_okay_bt.visible = true;
            }
            if(m_window.hasOwnProperty("share_bt"))
            {
               addWidget(this.m_share_bt = new FarmAnimatedTextButton(m_window["share_bt"],"Share!",this.onClose));
               this.m_share_bt.visible = true;
            }
            if(m_window.hasOwnProperty("title_tf"))
            {
               addWidget(this.m_title_tf = new ZwTextField(m_window["title_tf"],"Congrats!"));
               this.m_title_tf.visible = true;
            }
            if(m_window.hasOwnProperty("subtext1_tf"))
            {
               addWidget(this.m_subtext1_tf = new ZwTextField(m_window["subtext1_tf"],"Relevant Subtext1!"));
               if(!this.m_isFinderGrant)
               {
                  rewardItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_rewardName);
                  rewardFriendlyTitle = "a reward";
                  if(rewardItem)
                  {
                     rewardFriendlyTitle = rewardItem.friendlyTitle;
                  }
                  if(this.m_isBonusReward)
                  {
                     subText1 = "You completed the storybook! Here is your " + rewardFriendlyTitle + "!";
                  }
                  else
                  {
                     subText1 = "You won " + rewardFriendlyTitle + "!";
                  }
               }
               this.m_subtext1_tf.text = subText1;
               this.m_subtext1_tf.visible = !this.m_isFinderGrant;
            }
            if(m_window.hasOwnProperty("subtext2_tf"))
            {
               addWidget(this.m_subtext2_tf = new ZwTextField(m_window["subtext2_tf"],"Find it in your giftbox!"));
               if(this.m_isFinderGrant)
               {
                  subText2 = "You got Level " + String(this.m_FinderLevel + 1) + " Finder";
               }
               this.m_subtext2_tf.text = subText2;
               this.m_subtext2_tf.visible = true;
            }
         }
         if(this.manager.mainWindow)
         {
            this.manager.incrementActivePopupCount();
            this.manager.mainWindow.tintWindow();
            this.manager.mainWindow.enableInput = false;
         }
      }
      
      private function getFinderFeedURL(finderLevel:Number) : String
      {
         return FINDER_ICONS_PREFIX + String(finderLevel + 1) + FINDER_ICONS_SUFFIX;
      }
      
      private function getRewardFeedURL(rewardName:String) : String
      {
         var rewardItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_rewardName);
         return rewardItem.getImageByName(FarmItem.ICON_FEED);
      }
      
      private function onRewardPopupButtonClick(event:MouseEvent) : void
      {
         this.close();
      }
      
      private function onShareButtonClick(event:MouseEvent) : void
      {
         this.close();
      }
      
      private function get manager() : JumbleVillaManager
      {
         return JumbleVillaManager.getInstance(FEATURE_NAME);
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
         else
         {
            this.manager.showMainWindow();
         }
         super.onClose(event);
      }
   }
}

