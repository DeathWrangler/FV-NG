package Widgets.Windows
{
   import Classes.Constants.ZLocConstants;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Engine.Managers.TransactionManager;
   import Managers.SubscriberWalletManager;
   import Transactions.TGenericTransaction;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.SubscriberWalletTenSpinDialogFrame;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class SubscriberWalletTenSpinDialog extends FarmWindow
   {
      
      private var m_confirm_mc:MovieClip;
      
      private var m_animation_mc:MovieClip;
      
      private var m_npc_mc:MovieClip;
      
      private var m_tokenExchange_mc:MovieClip;
      
      private var m_data:Array;
      
      private var m_featureName:String;
      
      private var m_confirmBody:ZwTextField;
      
      private var m_body1_tf:ZwTextField;
      
      private var m_exchangeBodyDesc:ZwTextField;
      
      private var m_exchangeBt:FarmAnimatedTextButton;
      
      private var m_exchangeBody_tf:ZwTextField;
      
      private var m_result:Object;
      
      private var m_timer:Timer;
      
      protected var m_tutorial:ZwFrame = null;
      
      private var m_tutorialButton:FarmAnimatedTextButton;
      
      private var m_shareButton:FarmAnimatedTextButton;
      
      private var m_tutorialCurrentFrame:int = 1;
      
      private var m_tokenCount:int;
      
      private var tokenCounter_tf:ZwTextField;
      
      private var m_tokenAdded_tf:ZwTextField;
      
      private var m_rewards_mc:SubscriberWalletTenSpinDialogFrame;
      
      private var m_highestRewardType:String = "";
      
      private var m_highestRewardCode:String;
      
      private var m_tempTokenCount:int;
      
      public function SubscriberWalletTenSpinDialog(assetPath:String, tokenCount:int = -1, result:Object = null)
      {
         super(assetPath,true,true);
         this.m_featureName = SubscriberWalletManager.FEATURE_NAME;
         this.m_tokenCount = tokenCount;
         this.m_result = result;
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         addWidget(new ZwTextField(m_window.title_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_congrats")));
         this.m_confirm_mc = m_window.confirm_mc as MovieClip;
         addWidget(this.m_body1_tf = new ZwTextField(m_window.body1_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_tenRewardsBody1")),true);
         addWidget(new FarmAnimatedTextButton(this.m_confirm_mc.no_bt,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_goBack"),this.confirmNoCallback));
         addWidget(new FarmAnimatedTextButton(this.m_confirm_mc.yes_bt,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_exchange"),this.confirmYesCallback));
         this.m_confirmBody = new ZwTextField(this.m_confirm_mc["body_tf"],"0" + ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_tenRewardsExhange"));
         this.m_rewards_mc = new SubscriberWalletTenSpinDialogFrame(m_window.rewards_mc,this.m_featureName,this);
         this.m_tokenExchange_mc = m_window.tokenExchange_mc as MovieClip;
         this.m_tokenExchange_mc.visible = true;
         addWidget(this.m_exchangeBt = new FarmAnimatedTextButton(this.m_tokenExchange_mc.viewAll_bt,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_tenRewardsExhange_btnText"),this.exchangeForTokensCallback));
         this.m_exchangeBt.enabled = false;
         this.m_exchangeBodyDesc = new ZwTextField(this.m_tokenExchange_mc["body_tf"],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_tenRewardsExchangeBody"));
         this.m_exchangeBody_tf = new ZwTextField(this.m_tokenExchange_mc["exchangeBody_tf"],"0" + ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_tenRewardsExhange"));
         this.m_animation_mc = m_window.animation_mc as MovieClip;
         this.m_animation_mc.visible = true;
         this.m_npc_mc = m_window.NPC_mc as MovieClip;
         this.m_npc_mc.visible = true;
         (this.m_animation_mc["drumAnim_mc"] as MovieClip).stop();
         (this.m_animation_mc["purpleAnim_mc"] as MovieClip).stop();
         (this.m_animation_mc["silverAnim_mc"] as MovieClip).stop();
         (this.m_animation_mc["goldAnim_mc"] as MovieClip).stop();
         (this.m_animation_mc["purpleAnim_mc"] as MovieClip).visible = (this.m_animation_mc["silverAnim_mc"] as MovieClip).visible = (this.m_animation_mc["goldAnim_mc"] as MovieClip).visible = false;
         if(this.m_tokenCount != -1)
         {
            this.tokenCounter_tf = new ZwTextField(this.m_tokenExchange_mc["counter_tf"],this.m_tokenCount.toString() + "/30");
         }
         this.m_tokenAdded_tf = new ZwTextField(this.m_tokenExchange_mc["added_tf"],"0 " + ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_tokensAdded"));
         this.m_tokenAdded_tf.visible = false;
         if(this.m_result)
         {
            this.spinResultCallback(this.m_result);
         }
         else
         {
            TransactionManager.addTransaction(new TGenericTransaction(SubscriberWalletManager.SERVICE_CLASS,SubscriberWalletManager.SERVICE_FUNC_SPIN_IT,this.spinResultCallback,[this.m_featureName,SubscriberWalletManager.SPIN_PAID_10]),true);
         }
      }
      
      private function confirmNoCallback(event:Event) : void
      {
         var key:String = null;
         this.m_confirm_mc.visible = false;
         SubscriberWalletManager.getInstance().tenRewardExchangeButtonClick(false);
         this.m_npc_mc.visible = true;
         this.m_tokenExchange_mc.visible = true;
         var count:int = 0;
         for(key in this.m_data)
         {
            if(this.m_data[key].checked == true && this.m_data[key].freeze == false)
            {
               this.m_data[key].checked = false;
               count++;
            }
         }
         this.m_rewards_mc.setupSlotData(this.m_data);
         this.m_rewards_mc.refresh();
         this.m_rewards_mc.enabled = true;
         this.m_exchangeBt.enabled = false;
         this.m_tokenAdded_tf.visible = false;
         this.m_exchangeBody_tf.text = "0" + ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_tenRewardsExhange");
      }
      
      private function confirmYesCallback(event:Event) : void
      {
         var key:String = null;
         SubscriberWalletManager.getInstance().tenRewardExchangeButtonClick(false);
         var allFreezed:Boolean = true;
         var count:int = 0;
         for(key in this.m_data)
         {
            if(this.m_data[key].checked == true && this.m_data[key].freeze == false)
            {
               this.m_data[key].freeze = true;
               count++;
            }
            if(allFreezed)
            {
               allFreezed = Boolean(this.m_data[key].freeze);
            }
         }
         this.m_tokenAdded_tf.text = count.toString() + " " + ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_tokensAdded");
         this.m_tokenAdded_tf.visible = true;
         this.m_tokenCount += count;
         if(this.m_tokenCount > SubscriberWalletManager.getInstance().tokenMaxCount())
         {
            this.m_tokenCount = SubscriberWalletManager.getInstance().tokenMaxCount();
            this.m_tokenAdded_tf.visible = false;
         }
         this.tokenCounter_tf.text = this.m_tokenCount.toString() + "/" + SubscriberWalletManager.getInstance().tokenMaxCount();
         this.m_npc_mc.visible = true;
         this.m_tokenExchange_mc.visible = true;
         this.m_rewards_mc.setupSlotData(this.m_data);
         this.m_rewards_mc.refresh();
         this.m_confirm_mc.visible = false;
         this.m_exchangeBody_tf.text = "0" + ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_tenRewardsExhange");
         this.m_exchangeBt.enabled = false;
         this.m_rewards_mc.enabled = true;
      }
      
      override public function close() : void
      {
         super.close();
         SubscriberWalletManager.getInstance().updateReward(this.m_data);
      }
      
      public function spinResultCallback(result:Object) : void
      {
         var rewardType:String = null;
         var i:int = 0;
         this.m_data = new Array();
         result = result["rewards"];
         var rewardIndex:int = 0;
         for(rewardType in result)
         {
            for(i = 0; i < result[rewardType].length; i++)
            {
               this.m_data.push({
                  "rewardItemName":result[rewardType][i],
                  "type":rewardType,
                  "checked":false,
                  "index":rewardIndex,
                  "freeze":false
               });
               rewardIndex++;
               if(rewardType > this.m_highestRewardType)
               {
                  this.m_highestRewardType = rewardType;
                  this.m_highestRewardCode = result[rewardType][i];
               }
            }
         }
         switch(this.m_highestRewardType)
         {
            case "rare":
               this.playMC(this.m_animation_mc["silverAnim_mc"]);
               break;
            case "superrare":
               this.playMC(this.m_animation_mc["goldAnim_mc"]);
               break;
            case "ultrarare":
               this.playMC(this.m_animation_mc["purpleAnim_mc"]);
         }
         this.m_rewards_mc.setupSlotData(this.m_data);
         this.m_rewards_mc.refresh();
         this.m_rewards_mc.visible = false;
         if(this.m_timer == null)
         {
            this.m_timer = new Timer(5000,1);
            this.m_timer.addEventListener(TimerEvent.TIMER,this.stopAnimationAndShowReward);
            this.m_timer.start();
         }
         SubscriberWalletManager.getInstance().rewardStat(result,SubscriberWalletManager.SPIN_PAID_10);
      }
      
      private function playMC(element:MovieClip) : void
      {
         element.visible = true;
         element.gotoAndPlay(1);
      }
      
      public function exchangeForTokensCallback(event:Event) : void
      {
         if(this.m_tempTokenCount <= SubscriberWalletManager.getInstance().tokenMaxCount())
         {
            this.m_confirm_mc.visible = true;
            this.m_npc_mc.visible = false;
            SubscriberWalletManager.getInstance().tenRewardExchangeButtonClick(true);
            this.m_tokenExchange_mc.visible = false;
            this.m_rewards_mc.setupSlotData(this.m_data);
            this.m_rewards_mc.refresh();
            this.m_rewards_mc.enabled = false;
         }
      }
      
      public function updateTokenExchange(rewardIndex:int, checkedFlag:Boolean) : void
      {
         var key:String = null;
         var count:int = 0;
         for(key in this.m_data)
         {
            if(this.m_data[key].index == rewardIndex)
            {
               this.m_data[key].checked = checkedFlag;
            }
            if(this.m_data[key].checked == true && this.m_data[key].freeze == false)
            {
               count++;
            }
         }
         this.m_tempTokenCount = this.m_tokenCount + count;
         this.m_confirmBody.text = count.toString() + ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_tenRewardsExhange");
         this.m_exchangeBody_tf.text = count.toString() + ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_tenRewardsExhange");
         this.m_exchangeBt.enabled = count > 0;
         if(this.m_tempTokenCount > SubscriberWalletManager.getInstance().tokenMaxCount())
         {
            FarmGameUtil.disableButtonAndShowTooltip(this.m_exchangeBt,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_tenRewardsTokenLimitToolTip"));
            this.m_exchangeBody_tf.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_tenRewardsTokenLimit");
         }
      }
      
      public function stopAnimationAndShowReward(event:Event) : void
      {
         (this.m_animation_mc["drumAnim_mc"] as MovieClip).stop();
         this.m_animation_mc.visible = false;
         this.m_timer.stop();
         this.m_timer = null;
         this.showTutorial();
      }
      
      private function showTutorial() : void
      {
         var element:MovieClip = null;
         var i:int = 0;
         var child:MovieClip = null;
         this.m_rewards_mc.visible = true;
         if(!Global.player.getSeenFlag(this.m_featureName + "_TutorialTenSpin"))
         {
            this.m_npc_mc.visible = false;
            this.m_tutorial = addWidget(new ZwFrame(m_window.tokenFTUE_mc),false) as ZwFrame;
            this.m_tutorial.addWidget(this.m_tutorialButton = new FarmAnimatedTextButton(m_window.tokenFTUE_mc.okay_bt,ZLocUtils.t("Dialogs","Okay"),this.okayCallBack)) as FarmAnimatedTextButton;
            this.m_tutorialCurrentFrame = 1;
            if(this.m_tutorial != null)
            {
               element = this.m_tutorial.element as MovieClip;
               element.gotoAndStop(this.m_tutorialCurrentFrame++);
               for(i = 0; i < element.numChildren; i++)
               {
                  child = element.getChildAt(i) as MovieClip;
                  if(Boolean(child) && child != m_window.tokenFTUE_mc.okay_bt)
                  {
                     child.gotoAndPlay(1);
                  }
               }
               this.m_tutorial.visible = true;
            }
         }
      }
      
      private function okayCallBack(event:MouseEvent) : void
      {
         if(this.m_tutorialCurrentFrame < 4)
         {
            (this.m_tutorial.element as MovieClip).gotoAndStop(this.m_tutorialCurrentFrame++);
         }
         else
         {
            Global.player.setSeenFlag(this.m_featureName + "_TutorialTenSpin");
            this.m_tutorial.visible = false;
            this.m_npc_mc.visible = true;
         }
      }
      
      public function shareCallback(event:Event) : void
      {
         var item:FarmItem = Global.farmGameSettingsManager.getFarmItemByCode(this.m_highestRewardCode);
         SubscriberWalletManager.getInstance().bragFeed(item,this.m_highestRewardType);
         this.close();
      }
   }
}

