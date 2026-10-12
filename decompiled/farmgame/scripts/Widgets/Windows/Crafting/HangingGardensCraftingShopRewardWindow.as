package Widgets.Windows.Crafting
{
   import Classes.crafting.RecipeItem;
   import Classes.util.ZLocUtils;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Windows.FarmWindow;
   import flash.events.Event;
   
   public class HangingGardensCraftingShopRewardWindow extends FarmWindow
   {
      
      private static const REWARD_DIALOG_PREFIX:String = "hgcraftingshopRewardDialog_";
      
      private static const ASSET_PATH:String = "assets/dialogs/xhg/FV_xhg_craftshopRewards.swf";
      
      public static const EXPAND_SLOT_REWARD_TYPE:String = "slot";
      
      public static const RECIPE_COMPLETE_REWARD_TYPE:String = "complete";
      
      private var m_fCallBack:Function = null;
      
      private var m_rewardIcon:FarmIcon = null;
      
      private var m_rewardTrowels:String = null;
      
      private var m_recipeItem:RecipeItem = null;
      
      private var m_recipeFriendlyName:String = null;
      
      private var m_rewardType:String = null;
      
      public function HangingGardensCraftingShopRewardWindow(asset:String = null, recipeItem:RecipeItem = null, callbackFunc:Function = null, rewardType:String = "complete")
      {
         if(recipeItem)
         {
            this.m_recipeItem = recipeItem;
            this.m_rewardTrowels = this.m_recipeItem.worldCurrencyRewards.value.toString();
            this.m_recipeFriendlyName = this.m_recipeItem.friendlyTitle;
         }
         this.m_rewardType = rewardType;
         if(callbackFunc != null)
         {
            this.m_fCallBack = callbackFunc;
         }
         if(!asset)
         {
            asset = ASSET_PATH;
         }
         super(asset);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         if(m_window)
         {
            if(m_window.title_tf)
            {
               addWidget(new ZwTextField(m_window.title_tf,ZLocUtils.t("Dialogs",REWARD_DIALOG_PREFIX + "title")));
            }
            if(m_window.copy_tf)
            {
               addWidget(new ZwTextField(m_window.copy_tf,ZLocUtils.t("Dialogs",REWARD_DIALOG_PREFIX + "copy",{
                  "recipe":this.m_recipeFriendlyName,
                  "numTrowels":this.m_rewardTrowels
               })));
            }
            if(Boolean(m_window.trowels_tf) && Boolean(this.m_rewardTrowels))
            {
               addWidget(new ZwTextField(m_window.trowels_tf,this.m_rewardTrowels));
            }
            if(m_window.accept_bt)
            {
               addWidget(new FarmAnimatedTextButton(m_window.accept_bt,ZLocUtils.t("Dialogs",REWARD_DIALOG_PREFIX + "accept"),this.onClose));
            }
            if(m_window.animation_mc)
            {
               m_window.animation_mc.visible = true;
               m_window.animation_mc.gotoAndPlay(2);
            }
            if(Boolean(m_window.unlocked_mc) && this.m_rewardType == EXPAND_SLOT_REWARD_TYPE)
            {
               m_window.unlocked_mc.visible = true;
            }
            this.showRewardIcon();
         }
      }
      
      override protected function onClose(event:Event) : void
      {
         if(this.m_fCallBack != null)
         {
            this.m_fCallBack();
         }
         this.close();
      }
      
      private function showRewardIcon() : void
      {
         if(m_window.icon_mc)
         {
            this.m_rewardIcon = addWidget(new FarmIcon(m_window.icon_mc)) as FarmIcon;
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
}

