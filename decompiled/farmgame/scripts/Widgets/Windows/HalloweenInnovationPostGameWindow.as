package Widgets.Windows
{
   import Classes.Constants.ZLocConstants;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Managers.OrderBoard.HalloweenInnovationManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import flash.events.Event;
   
   public class HalloweenInnovationPostGameWindow extends FarmWindow
   {
      
      private static const OFFSET_OPF_Y:int = -30;
      
      protected var m_featureName:String = null;
      
      private var m_reward:FarmItem = null;
      
      private var m_callback:Function = null;
      
      protected var title_tf:ZwTextField = null;
      
      private var subTitle_tf:ZwTextField = null;
      
      private var fotterText:ZwTextField = null;
      
      protected var m_zoomingScale:int = 3;
      
      private var m_Accept_bt:FarmAnimatedTextButton;
      
      public function HalloweenInnovationPostGameWindow(dialogAsset:String, featureName:String, rewardItem:FarmItem = null, neighborId:String = "", buttonCallback:Function = null, dialogBackground:String = null)
      {
         super(dialogAsset);
         this.m_reward = rewardItem;
         this.m_featureName = featureName;
         this.m_callback = buttonCallback;
      }
      
      override protected function postLoadComplete() : void
      {
         var buttonCallback:Function = null;
         var iconUrl:String = null;
         super.postLoadComplete();
         if(m_window != null)
         {
            if(m_window.hasOwnProperty("generic_tf"))
            {
               this.title_tf = addWidget(new ZwTextField(m_window["generic_tf"],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_PostRedeemGameWindow_GenericText"))) as ZwTextField;
            }
            if(m_window.hasOwnProperty("generic2_tf"))
            {
               this.subTitle_tf = addWidget(new ZwTextField(m_window["generic2_tf"],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_PostRedeemGameWindow_Generic2Text",{"reward":this.m_reward.friendlyTitle}))) as ZwTextField;
            }
            if(m_window.hasOwnProperty("generic3_tf"))
            {
               this.fotterText = addWidget(new ZwTextField(m_window["generic3_tf"],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_PostGameWindow_Generic3Text"))) as ZwTextField;
            }
            if(m_window.hasOwnProperty("share_bt"))
            {
               buttonCallback = this.onButtonClick;
               if(this.m_callback != null)
               {
                  buttonCallback = this.m_callback;
               }
               addWidget(this.m_Accept_bt = new FarmAnimatedTextButton(m_window["okay_bt"],"Continue",buttonCallback));
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
            if(m_window.hasOwnProperty("giftbox_mc"))
            {
               m_window["giftbox_mc"].visible = true;
            }
         }
      }
      
      override protected function onLoadComplete(event:Event) : void
      {
         super.onLoadComplete(event);
         if(m_closeButton)
         {
            m_closeButton.visible = false;
         }
      }
      
      public function onButtonClick(event:Event) : void
      {
         this.close();
      }
      
      override public function close() : void
      {
         HalloweenInnovationManager.getInstance().conditionallyOpenBonusRewardWindow();
         super.close();
      }
   }
}

