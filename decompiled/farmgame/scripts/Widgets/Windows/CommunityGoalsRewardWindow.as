package Widgets.Windows
{
   import Classes.AutoConsumable;
   import Classes.CommunityGoals.CommunityGoalsRewardContainer;
   import Classes.ImageLoader;
   import Classes.util.ZLocUtils;
   import Managers.CommunityGoalsManager;
   import Managers.TemplateUIUtility;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   
   public class CommunityGoalsRewardWindow extends FarmWindow
   {
      
      private var m_title_tf:ZwTextField;
      
      private var m_description_tf:ZwTextField;
      
      private var m_leftArrow:DisplayObject;
      
      private var m_rightArrow:DisplayObject;
      
      private var m_item_tf:ZwTextField;
      
      private var m_giftbox:MovieClip;
      
      private var m_rewards:Array;
      
      private var itemDisplayed:int;
      
      private var m_container:CommunityGoalsRewardContainer;
      
      private var m_isFinalStageReward:Boolean;
      
      private var m_dialogBackground:String;
      
      private var m_bgLoader:ImageLoader = null;
      
      private var m_bgIcon:DisplayObject = null;
      
      public function CommunityGoalsRewardWindow(rewardXMLArray:Array, isFinalStageReward:Boolean = false, assetUrl:String = "assets/dialogs/FV_xsa_CommunityGoals_prize.swf", dialogBackground:String = null)
      {
         this.m_rewards = rewardXMLArray;
         this.m_isFinalStageReward = isFinalStageReward;
         super(assetUrl);
         this.m_dialogBackground = dialogBackground;
      }
      
      private function onBgLoad(dispObj:DisplayObject, info:Object = null) : void
      {
         this.m_bgIcon = dispObj;
         m_window.addChildAt(this.m_bgIcon,m_window.getChildIndex(m_window.mc_RewardDialog));
      }
      
      override protected function postLoadComplete() : void
      {
         var mc:MovieClip = null;
         super.postLoadComplete();
         var title_text:String = ZLocUtils.t("Dialogs","community_goals_Title");
         this.m_title_tf = new ZwTextField(m_window.title_tf,title_text);
         if(TemplateUIUtility.isTemplateUIEnabled(TemplateUIUtility.EXPANSION))
         {
            TemplateUIUtility.applyExpansionTextColor(m_window.title_tf);
            TemplateUIUtility.applyExpansionBevelFilter(m_window.title_tf);
            TemplateUIUtility.applyExpansionDropShadowFilter(m_window.title_tf);
         }
         addWidget(this.m_title_tf);
         var description_text:String = ZLocUtils.t("Dialogs","community_goals_Text");
         this.m_description_tf = new ZwTextField(m_window.description_tf,description_text);
         addWidget(this.m_description_tf);
         if(m_window.leftArrow_bt)
         {
            this.m_leftArrow = m_window.leftArrow_bt;
            this.m_leftArrow.addEventListener(MouseEvent.MOUSE_UP,this.prevPage);
         }
         if(m_window.rightArrow_bt)
         {
            this.m_rightArrow = m_window.rightArrow_bt;
            this.m_rightArrow.addEventListener(MouseEvent.MOUSE_UP,this.nextPage);
         }
         if(m_window.hasOwnProperty("snow_mc"))
         {
            mc = m_window.snow_mc as MovieClip;
            if(mc != null)
            {
               mc.visible = this.m_isFinalStageReward;
            }
         }
         if(m_window.hasOwnProperty("giftbox_mc"))
         {
            this.m_giftbox = m_window.giftbox_mc;
            if(this.m_giftbox)
            {
               this.m_giftbox.visible = false;
            }
         }
         if(Boolean(m_window.mc_RewardDialog) && Boolean(this.m_dialogBackground))
         {
            this.m_bgLoader = ImageLoader.getInstance(Global.getAssetURL(this.m_dialogBackground));
            this.m_bgLoader.getContent(this.onBgLoad);
         }
         addWidget(new FarmAnimatedTextButton(m_window.accept_bt,"Awesome!",onClose));
         m_window.info_tf.visible = true;
         if(TemplateUIUtility.isTemplateUIEnabled(TemplateUIUtility.EXPANSION))
         {
            TemplateUIUtility.applyExpansionGlowFilter(m_window.description_tf);
            TemplateUIUtility.applyExpansionSubTextColor(m_window.info_tf);
         }
         this.itemDisplayed = 0;
         this.refreshItem();
      }
      
      private function prevPage(e:MouseEvent = null) : void
      {
         if(this.itemDisplayed > 0)
         {
            --this.itemDisplayed;
            this.refreshItem();
         }
      }
      
      private function nextPage(e:MouseEvent = null) : void
      {
         if(this.itemDisplayed < this.m_rewards.length - 1)
         {
            ++this.itemDisplayed;
            this.refreshItem();
         }
      }
      
      private function refreshItem() : void
      {
         var reward:XML = null;
         if(Boolean(m_window.rewardContainer_mc) && Boolean(this.m_rewards[this.itemDisplayed]))
         {
            this.m_title_tf.visible = true;
            this.m_description_tf.visible = true;
            if(!this.m_container)
            {
               this.m_container = new CommunityGoalsRewardContainer(this.m_rewards[this.itemDisplayed],m_window.rewardContainer_mc,true);
            }
            else
            {
               this.m_container.refreshMC(this.m_rewards[this.itemDisplayed]);
            }
            this.m_container.visible = true;
            if(this.itemDisplayed <= 0)
            {
               this.m_leftArrow.visible = false;
            }
            else
            {
               this.m_leftArrow.visible = true;
            }
            if(this.itemDisplayed >= this.m_rewards.length - 1)
            {
               this.m_rightArrow.visible = false;
            }
            else
            {
               this.m_rightArrow.visible = true;
            }
         }
         if(this.m_giftbox)
         {
            reward = this.m_rewards[this.itemDisplayed];
            if(reward)
            {
               if(reward.@type == CommunityGoalsManager.REWARD_COMMUNITY)
               {
                  this.m_giftbox.visible = false;
               }
               else if(reward.@type == CommunityGoalsManager.REWARD_PLAYER)
               {
                  if(AutoConsumable.createAutoConsumable(reward.@name))
                  {
                     this.m_giftbox.visible = false;
                  }
                  else
                  {
                     this.m_giftbox.visible = true;
                  }
               }
            }
         }
      }
   }
}

