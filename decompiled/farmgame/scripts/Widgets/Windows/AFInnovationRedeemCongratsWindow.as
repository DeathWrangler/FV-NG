package Widgets.Windows
{
   import Classes.Constants.ZLocConstants;
   import Classes.ZItem.FarmItem;
   import Classes.feed.GenericRewardFeed;
   import Classes.util.ZLocUtils;
   import Managers.FarmStatsManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.ObjectPreviewFrame;
   import Widgets.Icons.FarmIcon;
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.geom.Point;
   
   public class AFInnovationRedeemCongratsWindow extends FarmWindow
   {
      
      private static const OFFSET_OPF_Y:int = -30;
      
      private static const BUNDLE_BONUS1_ID:String = "AfInnovation_BragBonus";
      
      protected var m_featureName:String = null;
      
      private var m_reward:FarmItem = null;
      
      private var m_callback:Function = null;
      
      protected var title_tf:ZwTextField = null;
      
      protected var m_zoomingScale:int = 3;
      
      private var m_bgIcon:DisplayObject = null;
      
      public function AFInnovationRedeemCongratsWindow(dialogAsset:String, featureName:String, rewardItem:FarmItem = null, buttonCallback:Function = null, dialogBackground:String = null)
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
         var itemName:String = "";
         if(this.m_reward != null)
         {
            itemName = this.m_reward.friendlyTitle;
         }
         if(m_window != null)
         {
            if(m_window.hasOwnProperty("generic_tf"))
            {
               this.title_tf = addWidget(new ZwTextField(m_window["generic_tf"],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_RedeemCongratsWindow_GenericText"))) as ZwTextField;
            }
            if(m_window.hasOwnProperty("generic2_tf"))
            {
               addWidget(new ZwTextField(m_window["generic2_tf"],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_RedeemCongratsWindow_Generic2Text",{"item":itemName})));
            }
            if(m_window.hasOwnProperty("generic3_tf"))
            {
               addWidget(new ZwTextField(m_window["generic3_tf"],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_RedeemCongratsWindow_Generic3Text")));
            }
            if(m_window.hasOwnProperty("generic4_tf"))
            {
               addWidget(new ZwTextField(m_window["generic4_tf"],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_RedeemCongratsWindow_Generic4Text")));
            }
            if(m_window.hasOwnProperty("share_bt"))
            {
               buttonCallback = this.onButtonClick;
               if(this.m_callback != null)
               {
                  buttonCallback = this.m_callback;
               }
               addWidget(new FarmAnimatedTextButton(m_window["share_bt"],"Share",buttonCallback));
            }
            if(m_window.hasOwnProperty("giftbox_mc"))
            {
               m_window["giftbox_mc"].visible = true;
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
            else if(m_window.hasOwnProperty("opf_mc"))
            {
               this.addWidget(new ObjectPreviewFrame(m_window.opf_mc,this.m_reward,null,[this.m_zoomingScale],null,"","",null,new Point(0,OFFSET_OPF_Y)));
            }
            if(Boolean(m_window.mc_RewardDialog) && Boolean(this.m_bgIcon))
            {
               m_window.addChildAt(this.m_bgIcon,m_window.getChildIndex(m_window.mc_RewardDialog));
            }
         }
      }
      
      public function onButtonClick(event:Event) : void
      {
         FarmStatsManager.count("Hand_of_Destiny","Rewards_UI","share");
         var _item:String = this.m_reward.name;
         if(_item)
         {
            new GenericRewardFeed(_item,BUNDLE_BONUS1_ID).shareFeed();
         }
         this.close();
      }
   }
}

