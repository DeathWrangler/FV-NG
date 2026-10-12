package Widgets.Windows
{
   import Classes.Constants.QuestConstants;
   import Classes.ZItem.FarmItem;
   import Classes.util.UserRewardUtil;
   import Classes.util.ZLocUtils;
   import Managers.FeatureConfigManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import flash.events.Event;
   
   public class BeanstalkRewardsWindow extends FarmWindow
   {
      
      private const ASSET_URL:String = "assets/dialogs/FV_RewardDialog2.swf";
      
      private var m_coinReward:int = 0;
      
      private var m_xpReward:int = 0;
      
      private var m_item:String = "";
      
      private var m_level:int = 0;
      
      private var m_featureName:String = "";
      
      private const COIN_X_OFFSET:int = 20;
      
      private const COIN_Y_OFFSET:int = 50;
      
      private const XP_X_OFFSET:int = 8;
      
      private const XP_Y_OFFSET:int = 20;
      
      public function BeanstalkRewardsWindow(featureName:String, level:int)
      {
         super(this.ASSET_URL);
         this.m_level = level;
         this.m_featureName = featureName;
      }
      
      private function awardRewards() : void
      {
         var coinRewardObject:Object = new Object();
         var xpRewardObject:Object = new Object();
         var itemRewardObject:Object = new Object();
         coinRewardObject.value = this.m_coinReward;
         coinRewardObject.type = QuestConstants.REWARD_COINS;
         xpRewardObject.value = this.m_xpReward;
         xpRewardObject.type = QuestConstants.REWARD_XP;
         itemRewardObject.value = this.m_item;
         itemRewardObject.type = QuestConstants.REWARD_GRANT_ITEM;
         UserRewardUtil.grantUserRewardsFromArray([coinRewardObject,xpRewardObject]);
      }
      
      override protected function postLoadComplete() : void
      {
         var itemIcon:FarmIcon = null;
         var text:String = null;
         var itemName:Array = null;
         var itemTf:ZwTextField = null;
         super.postLoadComplete();
         var configuration:FeatureConfigManager = FeatureConfigManager.getFeatureConfiguration(this.m_featureName);
         var levelUpCoinsConst:String = configuration.getStringConstant("levelUpCoins");
         var levelUpXpConst:String = configuration.getStringConstant("levelUpXp");
         var levelUpItemConst:String = configuration.getStringConstant("levelUpItem");
         this.m_coinReward = levelUpCoinsConst.split(",")[this.m_level];
         this.m_xpReward = levelUpXpConst.split(",")[this.m_level];
         var levelUpItemName:String = levelUpItemConst.split(",")[this.m_level];
         var levelUpItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(levelUpItemName);
         this.m_item = levelUpItem.code;
         var coinIcon:FarmIcon = new FarmIcon(m_window.icon1_mc,"assets/consumables/consume_coins_icon.png");
         var xpIcon:FarmIcon = new FarmIcon(m_window.icon2_mc,"assets/consumables/consume_xp_icon_small.png");
         if(this.m_item != null)
         {
            itemIcon = new FarmIcon(m_window.icon_mc,levelUpItem.iconUrl);
            text = levelUpItem.friendlyTitle;
            itemName = text.split(" ");
            itemTf = new ZwTextField(m_window.prize_tf,ZLocUtils.t("Dialogs","GiftAmount",{"quantity":itemName[0].toString()}));
            addWidget(itemIcon);
            addWidget(itemTf);
         }
         if(m_window.hasOwnProperty("share_bt"))
         {
            addWidget(new FarmAnimatedTextButton(m_window["share_bt"],ZLocUtils.t("Dialogs","Awesome"),this.onClose));
         }
         addWidget(new ZwTextField(m_window.prize1_tf,"+" + this.m_coinReward));
         addWidget(new ZwTextField(m_window.prize2_tf,"+" + this.m_xpReward));
         addWidget(new ZwTextField(m_window.master_1_tf,ZLocUtils.t("Dialogs","Retention_beanstalk_goal_level_" + this.m_level)));
         addWidget(new ZwTextField(m_window.master_3_tf,ZLocUtils.t("Dialogs","Retention_beanstalk_reward_text")));
         addWidget(coinIcon);
         addWidget(xpIcon);
         coinIcon.y -= this.COIN_Y_OFFSET;
         coinIcon.x -= this.COIN_X_OFFSET;
         xpIcon.y -= this.XP_Y_OFFSET;
         xpIcon.x -= this.XP_X_OFFSET;
      }
      
      override protected function onClose(event:Event) : void
      {
         super.onClose(event);
         this.awardRewards();
      }
   }
}

