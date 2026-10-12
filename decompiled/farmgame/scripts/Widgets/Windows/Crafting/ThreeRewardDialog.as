package Widgets.Windows.Crafting
{
   import Classes.Constants.QuestConstants;
   import Classes.crafting.RecipeItem;
   import Classes.util.ZLocUtils;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Windows.FarmWindow;
   import flash.events.Event;
   
   public class ThreeRewardDialog extends FarmWindow
   {
      
      private var m_fCallBack:Function = null;
      
      private var m_rewardIcon:FarmIcon = null;
      
      private var m_rewardXp:String = null;
      
      private var m_rewardCoins:String = null;
      
      private var m_recipeItem:RecipeItem = null;
      
      public function ThreeRewardDialog(asset:String, recipeItem:RecipeItem, fCallback:Function = null)
      {
         this.m_recipeItem = recipeItem;
         if(recipeItem.rewardsModern != null)
         {
            if(recipeItem.rewardsModern.hasOwnProperty(QuestConstants.REWARD_XP) && recipeItem.rewardsModern[QuestConstants.REWARD_XP] != null)
            {
               this.m_rewardXp = recipeItem.rewardsModern[QuestConstants.REWARD_XP].@value;
            }
            if(recipeItem.rewardsModern.hasOwnProperty(QuestConstants.REWARD_COINS) && recipeItem.rewardsModern[QuestConstants.REWARD_COINS] != null)
            {
               this.m_rewardCoins = recipeItem.rewardsModern[QuestConstants.REWARD_COINS].@value;
            }
         }
         if(fCallback != null)
         {
            this.m_fCallBack = fCallback;
         }
         super(asset);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         addWidget(new ZwTextField(m_window.title_tf,ZLocUtils.t("Dialogs",this.m_recipeItem.craft + "RewardDialog_title")));
         addWidget(new ZwTextField(m_window.copy_tf,ZLocUtils.t("Dialogs",this.m_recipeItem.craft + "RewardDialog_copy",{"item":this.m_recipeItem.friendlyTitle})));
         addWidget(new ZwTextField(m_window.coins_tf,this.m_rewardCoins));
         addWidget(new ZwTextField(m_window.xp_tf,this.m_rewardXp));
         addWidget(new FarmAnimatedTextButton(m_window.accept_bt,ZLocUtils.t("Dialogs","Accept"),this.onAcceptButtonClicked));
         this.m_rewardIcon = addWidget(new FarmIcon(m_window.icon_mc)) as FarmIcon;
         this.showRewardIcon();
      }
      
      private function onAcceptButtonClicked(event:Event) : void
      {
         if(this.m_fCallBack != null)
         {
            this.m_fCallBack();
         }
         this.close();
      }
      
      private function showRewardIcon() : void
      {
         if(this.m_recipeItem.image)
         {
            this.m_rewardIcon.loadIcon(this.m_recipeItem.image);
            this.m_rewardIcon.setSmoothing(true);
            this.m_rewardIcon.setIconSize(100,100);
            this.m_rewardIcon.visible = true;
         }
         else
         {
            this.m_rewardIcon.visible = false;
         }
      }
   }
}

