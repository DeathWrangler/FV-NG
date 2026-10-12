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
   import Widgets.Frames.ObjectPreviewFrame;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class SubscriberWalletOneSpinDialog extends FarmWindow
   {
      
      private var m_confirm_mc:MovieClip;
      
      private var m_animation_mc:MovieClip;
      
      private var m_body_tf:ZwTextField;
      
      private var m_body1_tf:ZwTextField;
      
      private var m_npc_mc:MovieClip;
      
      private var m_tkt_mc:MovieClip;
      
      private var m_share_bt:FarmAnimatedTextButton;
      
      private var m_tokenExchange_bt:FarmAnimatedTextButton;
      
      private var m_tokenExchange_mc:MovieClip;
      
      private var m_tokenExchangeBody_tf:ZwTextField;
      
      private var m_rewardCode:String;
      
      private var m_featureName:String = SubscriberWalletManager.FEATURE_NAME;
      
      private var m_rewardType:String;
      
      private var m_item:FarmItem;
      
      private var m_result:Object;
      
      private var m_timer:Timer;
      
      protected var m_tutorial:ZwFrame = null;
      
      private var m_tutorialButton:FarmAnimatedTextButton;
      
      private var m_tutorialCurrentFrame:int = 1;
      
      private var m_tokenCount:int = 1;
      
      private var m_iconPreview:ObjectPreviewFrame;
      
      private var m_spinType:int = 0;
      
      private var m_scene:int = 0;
      
      public function SubscriberWalletOneSpinDialog(assetPath:String, spinType:int = -1, result:Object = null, tokenCount:int = -1)
      {
         this.m_result = result;
         this.m_tokenCount = tokenCount;
         this.m_spinType = spinType;
         super(assetPath,true,true);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         addWidget(new ZwTextField(m_window.title_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_congrats")));
         addWidget(this.m_body_tf = new ZwTextField(m_window.body_tf,""));
         addWidget(this.m_body1_tf = new ZwTextField(m_window.body1_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_oneRewardsBody1")),true);
         this.m_confirm_mc = m_window.confirm_mc as MovieClip;
         addWidget(new FarmAnimatedTextButton(this.m_confirm_mc.no_bt,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_goBack"),this.confirmNoCallback));
         addWidget(new FarmAnimatedTextButton(this.m_confirm_mc.yes_bt,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_exchange"),this.confirmYesCallback));
         this.m_tokenExchange_mc = m_window.tokenExchange_mc as MovieClip;
         addWidget(this.m_tokenExchange_bt = new FarmAnimatedTextButton(this.m_tokenExchange_mc.viewAll_bt,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_exchangeForTokens"),this.exchangeForTokensCallback));
         this.m_tokenExchangeBody_tf = new ZwTextField(this.m_tokenExchange_mc["body_tf"],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_singleRewardExchange"));
         this.m_animation_mc = m_window["animation_mc"] as MovieClip;
         this.m_animation_mc.visible = true;
         (this.m_animation_mc["drumAnim_mc"] as MovieClip).stop();
         (this.m_animation_mc["drumAnim_mc"] as MovieClip).visible = true;
         (this.m_animation_mc["bronzeAnim_mc"] as MovieClip).stop();
         (this.m_animation_mc["purpleAnim_mc"] as MovieClip).stop();
         (this.m_animation_mc["silverAnim_mc"] as MovieClip).stop();
         (this.m_animation_mc["goldAnim_mc"] as MovieClip).stop();
         (this.m_animation_mc["bronzeAnim_mc"] as MovieClip).visible = (this.m_animation_mc["purpleAnim_mc"] as MovieClip).visible = (this.m_animation_mc["silverAnim_mc"] as MovieClip).visible = (this.m_animation_mc["goldAnim_mc"] as MovieClip).visible = false;
         this.m_npc_mc = m_window.NPC_mc as MovieClip;
         this.m_npc_mc.visible = true;
         this.m_tkt_mc = m_window["ticket_mc"] as MovieClip;
         if(this.m_result)
         {
            this.spinResultCallback(this.m_result);
         }
         else
         {
            TransactionManager.addTransaction(new TGenericTransaction(SubscriberWalletManager.SERVICE_CLASS,SubscriberWalletManager.SERVICE_FUNC_SPIN_IT,this.spinResultCallback,[this.m_featureName,this.m_spinType]),true);
         }
         if(this.m_tokenCount != -1)
         {
            new ZwTextField(this.m_tokenExchange_mc["counter_tf"],this.m_tokenCount.toString() + "/" + SubscriberWalletManager.getInstance().tokenMaxCount());
         }
         new ZwTextField(this.m_confirm_mc["body_tf"],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_exchangeBody"));
         if(this.m_tokenCount >= SubscriberWalletManager.getInstance().tokenMaxCount())
         {
            FarmGameUtil.disableButtonAndShowTooltip(this.m_tokenExchange_bt,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_tenRewardsTokenLimitToolTip"));
         }
      }
      
      public function shareCallback(event:Event) : void
      {
         SubscriberWalletManager.getInstance().bragFeed(this.m_item,this.m_rewardType);
         this.close();
      }
      
      public function spinResultCallback(result:Object, tokenCount:int = -1) : void
      {
         var rewardCode:String = null;
         var rewardCard:String = null;
         var rewardTypeText:String = "";
         SubscriberWalletManager.getInstance().updateMainUIVIP(result);
         if(result["rewards"].hasOwnProperty("common"))
         {
            this.m_rewardType = "common";
            rewardTypeText = "Great";
            rewardCard = "bronzeAnim_mc";
            this.m_scene = 1;
         }
         else if(result["rewards"].hasOwnProperty("rare"))
         {
            this.m_rewardType = "rare";
            rewardTypeText = "Rare";
            this.m_scene = 2;
            rewardCard = "silverAnim_mc";
         }
         else if(result["rewards"].hasOwnProperty("superrare"))
         {
            this.m_rewardType = "superrare";
            rewardTypeText = "Super Rare";
            rewardCard = "goldAnim_mc";
            this.m_scene = 3;
         }
         else if(result["rewards"].hasOwnProperty("ultrarare"))
         {
            this.m_rewardType = "ultrarare";
            rewardTypeText = "ULTRA RARE";
            this.m_scene = 4;
            rewardCard = "purpleAnim_mc";
         }
         rewardCode = result["rewards"][this.m_rewardType][0];
         if(this.m_animation_mc)
         {
            (this.m_animation_mc[rewardCard] as MovieClip).visible = true;
            (this.m_animation_mc[rewardCard] as MovieClip).play();
         }
         if(this.m_timer == null)
         {
            this.m_timer = new Timer(5000,1);
            this.m_timer.addEventListener(TimerEvent.TIMER,this.stopAnimationAndShowReward);
            this.m_timer.start();
         }
         this.m_body_tf.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_singleSpinRewardDesc",{"rewardType":rewardTypeText});
         this.m_rewardCode = rewardCode;
         this.m_item = Global.farmGameSettingsManager.getFarmItemByCode(this.m_rewardCode);
         SubscriberWalletManager.getInstance().rewardStat(result["rewards"],this.m_spinType);
      }
      
      private function confirmNoCallback(event:Event) : void
      {
         this.m_confirm_mc.visible = false;
         this.m_npc_mc.visible = true;
      }
      
      private function confirmYesCallback(event:Event) : void
      {
         super.close();
         SubscriberWalletManager.getInstance().updateReward2([]);
      }
      
      override public function close() : void
      {
         super.close();
         SubscriberWalletManager.getInstance().updateReward2([this.m_rewardCode]);
      }
      
      private function exchangeForTokensCallback(event:Event) : void
      {
         if(this.m_tokenCount < SubscriberWalletManager.getInstance().tokenMaxCount())
         {
            this.m_confirm_mc.visible = true;
            this.m_npc_mc.visible = false;
         }
      }
      
      public function stopAnimationAndShowReward(event:Event) : void
      {
         if(this.m_animation_mc)
         {
            this.m_animation_mc.visible = false;
         }
         this.m_timer.stop();
         this.m_timer = null;
         this.m_tokenExchange_mc.visible = SubscriberWalletManager.getInstance().isTokenFeatureAvailable();
         this.m_tkt_mc.visible = true;
         this.m_tkt_mc.gotoAndStop(this.m_scene);
         this.m_iconPreview = new ObjectPreviewFrame(m_window["icon_mc"],this.m_item,null,null,[200]);
         this.m_iconPreview.visible = true;
         this.m_iconPreview.attachTooltip(new FarmTextTooltip(this.m_item.friendlyTitle));
         this.showTutorial();
      }
      
      override protected function release() : void
      {
         this.m_timer = null;
         super.release();
      }
      
      private function showTutorial() : void
      {
         var element:MovieClip = null;
         var i:int = 0;
         var child:MovieClip = null;
         if(!Global.player.getSeenFlag(this.m_featureName + "_TutorialOneSpin") && !Global.player.getSeenFlag(this.m_featureName + "_TutorialTenSpin") && SubscriberWalletManager.getInstance().isTokenFeatureAvailable())
         {
            this.m_npc_mc.visible = false;
            this.m_tutorial = addWidget(new ZwFrame(m_window.tokneFTUE_mc),false) as ZwFrame;
            this.m_tutorial.addWidget(this.m_tutorialButton = new FarmAnimatedTextButton(m_window.tokneFTUE_mc.okay_bt,ZLocUtils.t("Dialogs","Okay"),this.okayCallBack)) as FarmAnimatedTextButton;
            this.m_tutorialCurrentFrame = 1;
            if(this.m_tutorial != null)
            {
               element = this.m_tutorial.element as MovieClip;
               element.gotoAndStop(this.m_tutorialCurrentFrame++);
               for(i = 0; i < element.numChildren; i++)
               {
                  child = element.getChildAt(i) as MovieClip;
                  if(Boolean(child) && child != m_window.tokneFTUE_mc.okay_bt)
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
            Global.player.setSeenFlag(this.m_featureName + "_TutorialOneSpin");
            this.m_tutorial.visible = false;
            this.m_npc_mc.visible = true;
         }
      }
   }
}

