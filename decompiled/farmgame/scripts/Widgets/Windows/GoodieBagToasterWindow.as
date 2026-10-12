package Widgets.Windows
{
   import Classes.Friend;
   import Classes.NeighborActions.NeighborActionConstants;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Engine.Managers.TransactionManager;
   import Managers.FarmStatsManager;
   import Transactions.TCancelFriendReward;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import flash.events.Event;
   
   public class GoodieBagToasterWindow extends ToasterWindow
   {
      
      private static const ASSET_PATH:String = "assets/dialogs/FV_GoodieBag_Toaster.swf";
      
      private static const GOODIE_BAG_FEED_BUNDLE_ID:String = "NeighborVisitGoodieBag";
      
      private static const ICON_WIDTH_HEIGHT:Number = 50;
      
      private var m_giftItem:FarmItem = null;
      
      private var m_friendId:String = "0";
      
      private var m_rewardUrl:String = "";
      
      public function GoodieBagToasterWindow(friendId:String, giftItem:FarmItem, rewardUrl:String)
      {
         this.m_giftItem = giftItem;
         this.m_friendId = friendId;
         this.m_rewardUrl = rewardUrl;
         super(ASSET_PATH);
      }
      
      override protected function postLoadComplete() : void
      {
         var itemIcon:FarmIcon = null;
         var friend:Friend = null;
         var friendName:String = null;
         var friendPicIcon:FarmIcon = null;
         super.postLoadComplete();
         if(Boolean(m_window) && Boolean(m_window.goodieToaster_mc))
         {
            m_window.goodieToaster_mc.visible = true;
            addWidget(new FarmAnimatedButton(m_window.goodieToaster_mc.share_bt,this.onShare));
            addWidget(new FarmButton(m_window.goodieToaster_mc.close_bt,this.onClose));
            addWidget(new ZwTextField(m_window.goodieToaster_mc.item_tf,ZLocUtils.tk_pk_asTitle(this.m_giftItem.friendlyName)));
            itemIcon = new FarmIcon(m_window.goodieToaster_mc.icon_mc,this.m_giftItem.icon);
            itemIcon.setIconSize(ICON_WIDTH_HEIGHT,ICON_WIDTH_HEIGHT);
            addWidget(itemIcon);
            friend = Global.friendManager.getFriendData(this.m_friendId);
            friendName = friend.name;
            if(friendName == "")
            {
               friendName = ZLocUtils.t("FarmGame","HaveNoFriendNameData");
            }
            addWidget(new ZwTextField(m_window.goodieToaster_mc.name_tf,friendName));
            friendPicIcon = new FarmIcon(m_window.goodieToaster_mc.friendPic_mc,friend.picture);
            friendPicIcon.setIconSize(ICON_WIDTH_HEIGHT,ICON_WIDTH_HEIGHT);
            addWidget(friendPicIcon);
            ZLocUtils.setText(m_window,"goodieToaster_mc.share_bt","Dialogs","Share");
            ZLocUtils.setText(m_window,"goodieToaster_mc.title_tf","Dialogs","neighborVisitGoodieBagToaster_title");
            ZLocUtils.setText(m_window,"goodieToaster_mc.generic_tf","Dialogs","neighborVisitGoodieBagToaster_body");
         }
      }
      
      private function onShare(event:Event) : void
      {
         FarmStatsManager.count(NeighborActionConstants.GOODIE_BAG_COUNTER_NAME,"reward_toaster_click_share");
         var bundleId:String = GOODIE_BAG_FEED_BUNDLE_ID;
         var iconUrl:String = this.m_giftItem.icon;
         var params:Object = new Object();
         params.sendingUser = Global.player.firstName;
         params.itemName = this.m_giftItem.friendlyName;
         params.rewardLink = this.m_rewardUrl;
         var neighborName:String = Global.friendManager.getFriendName(this.m_friendId,true);
         params.neighborName = neighborName != "" ? neighborName : "FarmGame:HaveNoFriendNameData";
         params.images = [{
            "src":iconUrl,
            "href":"{SN_APP_URL}" + this.m_rewardUrl
         }];
         GlobalEngine.socialNetwork.publishFeedStory(bundleId,params,[],false);
         close();
      }
      
      override protected function onClose(event:Event) : void
      {
         TransactionManager.addTransaction(new TCancelFriendReward([this.m_rewardUrl]));
         super.onClose(event);
      }
      
      override protected function postShow() : void
      {
         FarmStatsManager.count(NeighborActionConstants.GOODIE_BAG_COUNTER_NAME,"reward_toaster_impressions");
      }
      
      override protected function postClose() : void
      {
         FarmStatsManager.count(NeighborActionConstants.GOODIE_BAG_COUNTER_NAME,"reward_toaster_click_cancel");
      }
   }
}

