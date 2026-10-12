package Widgets.Windows
{
   import Classes.Constants.ZLocConstants;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Managers.OctoberSidecarFeatureManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class OctoberSidecarFeatureRewardPopup extends FarmWindow
   {
      
      private static const FEATURE_NAME:String = "GilroysParade";
      
      private var m_featureName:String = null;
      
      private const TYPE_ITEM_COMPLETE:int = 1;
      
      private const TYPE_MILESTONE:int = 2;
      
      private const TYPE_GRANT_DECO:int = 3;
      
      private var m_popupType:int;
      
      private var m_shareCallback:Function;
      
      private var m_rewardItem:FarmItem;
      
      private var m_title_tf:ZwTextField;
      
      private var m_subtext1_tf:ZwTextField;
      
      private var m_subtext2_tf:ZwTextField;
      
      private var m_reward_icon:FarmIcon;
      
      private var m_npc_mc:MovieClip;
      
      private var m_accept_bt:FarmAnimatedTextButton;
      
      private var m_share_bt:FarmAnimatedTextButton;
      
      public function OctoberSidecarFeatureRewardPopup(featureName:String = "GilroysParade", assetUrl:String = null, rewardItem:FarmItem = null, popupType:int = 0, shareCallback:Function = null)
      {
         this.m_featureName = featureName;
         this.m_rewardItem = rewardItem;
         this.m_shareCallback = shareCallback;
         this.m_popupType = popupType;
         super(assetUrl);
      }
      
      override protected function postLoadComplete() : void
      {
         var iconPath:String = null;
         super.postLoadComplete();
         this.setWindowPosition();
         if(m_window.hasOwnProperty("title_tf"))
         {
            this.m_title_tf = new ZwTextField(m_window["title_tf"]);
         }
         if(m_window.hasOwnProperty("icon_mc"))
         {
            if(this.m_rewardItem)
            {
               iconPath = this.m_rewardItem.getImageByName(FarmItem.ICON_FEED);
               if(iconPath == null)
               {
                  iconPath = this.m_rewardItem.iconUrl;
               }
               this.m_reward_icon = new FarmIcon(m_window["icon_mc"],iconPath);
               this.m_reward_icon.setIconSize(185,185);
               this.m_reward_icon.visible = true;
            }
         }
         if(m_window.hasOwnProperty("npc_mc"))
         {
            this.m_npc_mc = m_window["npc_mc"] as MovieClip;
            this.m_npc_mc.visible = this.m_popupType == 3 ? true : false;
         }
         if(m_window.hasOwnProperty("item_tf"))
         {
            if(this.m_rewardItem)
            {
               this.m_subtext1_tf = new ZwTextField(m_window["item_tf"]);
            }
         }
         if(m_window.hasOwnProperty("info_tf"))
         {
            if(this.m_rewardItem)
            {
               this.m_subtext2_tf = new ZwTextField(m_window["info_tf"]);
            }
         }
         if(m_window.hasOwnProperty("giftbox_mc"))
         {
            (m_window["giftbox_mc"] as MovieClip).visible = true;
         }
         if(m_window.hasOwnProperty("accept_bt"))
         {
            this.m_accept_bt = new FarmAnimatedTextButton(m_window["accept_bt"],"Awesome!",this.onAcceptClick);
            this.m_accept_bt.visible = false;
         }
         if(m_window.hasOwnProperty("share_bt"))
         {
            this.m_share_bt = new FarmAnimatedTextButton(m_window["share_bt"],"Share",this.onShareClick);
            this.m_share_bt.visible = false;
         }
         this.populateBasedOnType();
      }
      
      private function populateBasedOnType() : *
      {
         if(this.m_popupType == this.TYPE_ITEM_COMPLETE)
         {
            if(this.m_title_tf)
            {
               this.m_title_tf.text = "Congrats!";
               this.m_title_tf.visible = true;
            }
            if(Boolean(this.m_subtext1_tf) && Boolean(this.m_rewardItem))
            {
               this.m_subtext1_tf.text = "You have got a " + this.m_rewardItem.friendlyTitle + " !";
               this.m_subtext1_tf.visible = true;
            }
            if(this.m_accept_bt)
            {
               this.m_accept_bt.visible = true;
            }
         }
         else if(this.m_popupType == this.TYPE_MILESTONE)
         {
            if(this.m_title_tf)
            {
               this.m_title_tf.text = "Yay! Yay!";
               this.m_title_tf.visible = true;
            }
            if(this.m_subtext1_tf)
            {
               this.m_subtext1_tf.text = "We just found " + this.manager.completedItemsCount + " items!";
               this.m_subtext1_tf.visible = true;
            }
            if(Boolean(this.m_subtext2_tf) && Boolean(this.m_rewardItem))
            {
               this.m_subtext2_tf.text = "You have won a " + this.m_rewardItem.friendlyTitle + "!";
               this.m_subtext2_tf.visible = true;
            }
            if(this.m_share_bt)
            {
               this.m_share_bt.visible = true;
            }
         }
         else if(this.m_popupType == this.TYPE_GRANT_DECO)
         {
            if(this.m_title_tf)
            {
               this.m_title_tf.text = "Hurray!";
               this.m_title_tf.visible = true;
            }
            if(Boolean(this.m_subtext1_tf) && Boolean(this.m_rewardItem))
            {
               this.m_subtext1_tf.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_rewardItem.name + "_" + FEATURE_NAME + "_FoundText");
               this.m_subtext1_tf.visible = true;
            }
            if(Boolean(this.m_subtext2_tf) && Boolean(this.m_rewardItem))
            {
               this.m_subtext2_tf.text = "You found the " + this.m_rewardItem.friendlyTitle + "!";
               this.m_subtext2_tf.visible = true;
            }
            if(this.m_accept_bt)
            {
               this.m_accept_bt.text = "Interesting!";
               this.m_accept_bt.visible = true;
            }
         }
      }
      
      private function onAcceptClick(e:Event = null) : void
      {
         this.close();
      }
      
      private function onShareClick(e:Event = null) : void
      {
         if(Boolean(this.m_shareCallback))
         {
            this.m_shareCallback.call();
         }
         this.close();
      }
      
      private function setWindowPosition() : void
      {
         if(m_window)
         {
            m_window.x += 70;
            m_window.y += 100;
         }
      }
      
      private function get manager() : OctoberSidecarFeatureManager
      {
         return OctoberSidecarFeatureManager.getInstance(FEATURE_NAME);
      }
      
      override public function close() : void
      {
         if(this.manager.m_mainWindow)
         {
            this.manager.m_mainWindow.enableInput = true;
            this.manager.m_mainWindow.untintWindow();
         }
         super.close();
      }
   }
}

