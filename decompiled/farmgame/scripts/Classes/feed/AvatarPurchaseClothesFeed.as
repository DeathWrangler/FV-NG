package Classes.feed
{
   import Classes.Avatar.AvatarItem;
   import Classes.Avatar.AvatarManager;
   import Classes.Avatar.FarmAvatar;
   import Classes.UGC.UGCAvatarFeedImage;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Constants;
   import Events.GenericPopupEvent;
   import Managers.UserContentManager;
   import Widgets.Windows.Market.MarketWindow;
   
   public class AvatarPurchaseClothesFeed extends FarmFeed
   {
      
      private const FEED_ICON_URL:String = "assets/newsfeed/avatarshopping.png";
      
      private var m_originalDirection:Number;
      
      private var m_lastItemPurchased:AvatarItem;
      
      public function AvatarPurchaseClothesFeed(lastItemPurchased:AvatarItem)
      {
         super();
         this.m_lastItemPurchased = lastItemPurchased;
      }
      
      public function startFeedFlow() : void
      {
         UI.displayMessage(ZLocUtils.t("Dialogs","AvatarPurchaseFeedPrompt"),GenericPopup.TYPE_SHARECANCEL,this.onCloseFeedPrompt);
      }
      
      private function onCloseFeedPrompt(event:GenericPopupEvent) : void
      {
         var playerAvatar:FarmAvatar = null;
         var ugcAvatar:UGCAvatarFeedImage = null;
         if(event.button == GenericPopup.ACCEPT)
         {
            playerAvatar = Global.player.avatar;
            this.m_originalDirection = playerAvatar.getDirection();
            playerAvatar.setPlayerAvatarDirection(Constants.DIRECTION_SE);
            ugcAvatar = new UGCAvatarFeedImage(Global.player.avatar,UserContentManager.FEATURE_AVATAR_APPEARANCE);
            UserContentManager.getInstance().createFeedImage(ugcAvatar,this.onFeedImageGenerated);
         }
         else
         {
            this.conditionallyShowMarket();
         }
      }
      
      private function onFeedImageGenerated(result:Object) : void
      {
         m_publishCallback = this.conditionallyShowMarket;
         m_bundleId = "AvatarPurchaseClothes";
         var iconUrl:String = result.imagePath;
         var playerAvatar:FarmAvatar = Global.player.avatar;
         playerAvatar.setPlayerAvatarDirection(this.m_originalDirection);
         m_params.images = [{
            "src":iconUrl,
            "href":"{SN_APP_URL}"
         }];
         m_params.userName = Global.player.firstName;
         m_params.itemName = this.m_lastItemPurchased.friendlyName;
         publish();
         this.m_lastItemPurchased = null;
      }
      
      private function conditionallyShowMarket() : void
      {
         if(AvatarManager.isLastPurchaseFromMarket())
         {
            UI.displayMarketDialog("avatarClothesFeed",MarketWindow.previousType,null,MarketWindow.previousSubType);
         }
      }
   }
}

