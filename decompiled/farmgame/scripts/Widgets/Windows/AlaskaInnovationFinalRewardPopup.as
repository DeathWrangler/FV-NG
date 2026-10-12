package Widgets.Windows
{
   import Classes.Constants.ZLocConstants;
   import Classes.ImageLoader;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   
   public class AlaskaInnovationFinalRewardPopup extends FarmWindow
   {
      
      protected var m_featureName:String = null;
      
      private var m_reward:FarmItem = null;
      
      private var m_callback:Function = null;
      
      protected var title_tf:ZwTextField = null;
      
      protected var m_zoomingScale:int = 3;
      
      private var m_dialogBackground:String;
      
      private var m_position:int;
      
      private var m_bgLoader:ImageLoader = null;
      
      private var m_bgIcon:DisplayObject = null;
      
      public function AlaskaInnovationFinalRewardPopup(dialogAsset:String, featureName:String, rewardItem:FarmItem = null, buttonCallback:Function = null, position:int = 0, bonusItems:Array = null, dialogBackground:String = null)
      {
         dialogAsset = "assets/dialogs/alaska/innovation/FV_xsu_Innovation_Position.swf";
         super(dialogAsset,true,true);
         this.m_reward = rewardItem;
         this.m_featureName = featureName;
         this.m_callback = buttonCallback;
         this.m_dialogBackground = dialogBackground;
         this.m_position = position;
         if(this.m_dialogBackground != null)
         {
            this.m_bgLoader = ImageLoader.getInstance(Global.getAssetURL(this.m_dialogBackground));
            this.m_bgLoader.getContent(this.onBgLoad);
         }
      }
      
      private function onBgLoad(dispObj:DisplayObject, info:Object = null) : void
      {
         this.m_bgIcon = dispObj;
      }
      
      override protected function postLoadComplete() : void
      {
         var buttonCallback:Function = null;
         var rewardmc:MovieClip = null;
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
               this.title_tf = addWidget(new ZwTextField(m_window["generic_tf"],"Congratulations!")) as ZwTextField;
            }
            if(m_window.hasOwnProperty("generic2_tf"))
            {
               addWidget(new ZwTextField(m_window["generic2_tf"],"You have been rewarded for your hardwork and cookies sold!!"));
            }
            if(m_window.hasOwnProperty("share_bt"))
            {
               buttonCallback = onClose;
               if(this.m_callback != null)
               {
                  buttonCallback = this.m_callback;
               }
               addWidget(new FarmAnimatedTextButton(m_window["share_bt"],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "ShareButtonText",{"itemName":itemName}),buttonCallback));
            }
            else if(m_window.hasOwnProperty("accept_bt"))
            {
               buttonCallback = onClose;
               if(this.m_callback != null)
               {
                  buttonCallback = this.m_callback;
               }
               addWidget(new FarmAnimatedTextButton(m_window["accept_bt"],"Awesome",buttonCallback));
            }
            if(Boolean(m_window.mc_RewardDialog) && Boolean(this.m_bgIcon))
            {
               m_window.addChildAt(this.m_bgIcon,m_window.getChildIndex(m_window.mc_RewardDialog));
            }
            if(m_window.hasOwnProperty("reward_mc"))
            {
               rewardmc = m_window["reward_mc"] as MovieClip;
               rewardmc.visible = true;
               rewardmc.gotoAndStop(this.m_position);
            }
         }
      }
   }
}

