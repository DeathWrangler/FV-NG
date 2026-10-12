package Widgets.Windows
{
   import Classes.Constants.ZLocConstants;
   import Classes.util.ZLocUtils;
   import Managers.WanderingPirateManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class WanderingPirateRewardPopup extends FarmWindow
   {
      
      private var m_keyBoxNumber:int;
      
      protected var m_featureName:String = null;
      
      private var m_callback:Function = null;
      
      protected var title_tf:ZwTextField = null;
      
      protected var generic2_tf:ZwTextField = null;
      
      protected var generic3_tf:ZwTextField = null;
      
      protected var share_bt:FarmAnimatedTextButton = null;
      
      protected var accept_bt:FarmAnimatedTextButton = null;
      
      private var m_reward:Object = null;
      
      private var m_shipPartBg:ZwWidget = null;
      
      private var m_rewardmc:MovieClip = null;
      
      public function WanderingPirateRewardPopup(dialogAsset:String, featureName:String, rewardItem:Object = null, buttonCallback:Function = null, keyBoxNumber:int = 0)
      {
         super(dialogAsset);
         this.m_featureName = featureName;
         this.m_callback = buttonCallback;
         this.m_keyBoxNumber = keyBoxNumber;
         this.m_reward = rewardItem;
      }
      
      override protected function postLoadComplete() : void
      {
         var mapSeenFlag:Boolean = false;
         var mapStage:int = 0;
         var numMaps:int = 0;
         var rewardFrameString:String = null;
         var buttonCallback2:Function = null;
         super.postLoadComplete();
         var itemName:String = "";
         if(this.m_reward != null)
         {
            itemName = this.m_reward.friendlyTitle;
         }
         if(m_window != null)
         {
            if(m_window.hasOwnProperty("generic_tf"))
            {
               this.title_tf = addWidget(new ZwTextField(m_window["generic_tf"],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "GenericText",{"itemName":itemName}))) as ZwTextField;
            }
            if(m_window.hasOwnProperty("generic2_tf"))
            {
               this.generic2_tf = addWidget(new ZwTextField(m_window["generic2_tf"],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "Generic2Text",{"itemName":itemName}))) as ZwTextField;
            }
            if(m_window.hasOwnProperty("generic3_tf"))
            {
               this.generic3_tf = addWidget(new ZwTextField(m_window["generic3_tf"],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "Generic3Text",{"itemName":itemName}))) as ZwTextField;
               this.generic3_tf.visible = false;
            }
            if(m_window.hasOwnProperty("share_bt"))
            {
               this.share_bt = addWidget(new FarmAnimatedTextButton(m_window["share_bt"],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "ShareButtonText",{"itemName":itemName}),this.onShareButtonClicked)) as FarmAnimatedTextButton;
               this.share_bt.visible = false;
            }
            if(m_window.hasOwnProperty("accept_bt"))
            {
               buttonCallback2 = onClose;
               this.accept_bt = addWidget(new FarmAnimatedTextButton(m_window["accept_bt"],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"Awesome",{"itemName":itemName}),buttonCallback2)) as FarmAnimatedTextButton;
               this.accept_bt.visible = true;
            }
            if(m_window.hasOwnProperty("size_mc"))
            {
               this.m_shipPartBg = addWidget(new ZwWidget(m_window["size_mc"]),false) as ZwWidget;
               this.m_shipPartBg.visible = false;
            }
            mapSeenFlag = Global.player.getSeenFlag(WanderingPirateManager.FEATURE_NAME + this.m_keyBoxNumber);
            mapStage = WanderingPirateManager.getInstance(WanderingPirateManager.FEATURE_NAME).getMapStageForUser();
            numMaps = mapStage > WanderingPirateManager.NUM_OF_CASES ? WanderingPirateManager.NUM_OF_CASES : mapStage;
            rewardFrameString = "finalShipAnim_" + (numMaps - 1) + "_mc";
            this.m_rewardmc = m_window[rewardFrameString] as MovieClip;
            if(this.m_rewardmc)
            {
               this.m_rewardmc.visible = true;
               this.m_rewardmc.play();
            }
            if(numMaps >= WanderingPirateManager.NUM_OF_CASES)
            {
               this.share_bt.visible = true;
               this.accept_bt.visible = false;
               this.generic3_tf.visible = true;
               this.m_shipPartBg.visible = true;
               this.title_tf.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "GenericTextFinal");
               this.generic2_tf.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "GenericTextFinal2");
            }
            if(!mapSeenFlag)
            {
               Global.player.setSeenFlag(WanderingPirateManager.FEATURE_NAME + this.m_keyBoxNumber,true);
            }
         }
      }
      
      private function onShareButtonClicked(event:Event = null) : void
      {
         if(this.share_bt)
         {
            this.share_bt.enabled = false;
         }
         WanderingPirateManager.getInstance(WanderingPirateManager.FEATURE_NAME).onBragFeed(WanderingPirateManager.FINAL_REWARD);
         close();
      }
   }
}

