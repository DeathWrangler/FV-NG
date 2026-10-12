package Display
{
   import Classes.util.ZLocUtils;
   import Events.GenericPopupEvent;
   
   public class WishlistNotifyPopup extends GenericPopupTitle
   {
      
      protected var m_wishImage:String;
      
      protected var m_wishRewardLink:String;
      
      protected var m_wishName:String;
      
      public function WishlistNotifyPopup(wishSenders:Array, wishImage:String, wishRewardLink:String, wishName:String)
      {
         this.m_wishImage = wishImage;
         this.m_wishRewardLink = wishRewardLink;
         this.m_wishName = wishName;
         var senderNames:String = ZLocUtils.t("Dialogs","wishlist_your_friends");
         var sender1Name:String = null;
         var sender2Name:String = null;
         var sender1Gender:String = null;
         var sender2Gender:String = null;
         switch(wishSenders.length)
         {
            case 1:
               if(Global.friendManager.getFriendName(wishSenders[0]) != null)
               {
                  senderNames = Global.friendManager.getFriendName(wishSenders[0]);
               }
               break;
            case 2:
               sender1Name = Global.friendManager.getFriendName(wishSenders[0]);
               sender2Name = Global.friendManager.getFriendName(wishSenders[1]);
               if(sender1Name != null && sender2Name != null)
               {
                  sender1Gender = Global.friendManager.getFriendGender(wishSenders[0]);
                  sender2Gender = Global.friendManager.getFriendGender(wishSenders[1]);
                  senderNames = ZLocUtils.t("Dialogs","friendA_and_friendB",{
                     "userA":ZLocUtils.tn(sender1Name,ZLocUtils.tg(sender1Gender)),
                     "userB":ZLocUtils.tn(sender2Name,ZLocUtils.tg(sender2Gender))
                  });
               }
               break;
            default:
               sender1Name = Global.friendManager.getFriendName(wishSenders[0]);
               sender2Name = Global.friendManager.getFriendName(wishSenders[1]);
               if(sender1Name != null && sender2Name != null)
               {
                  sender1Gender = Global.friendManager.getFriendGender(wishSenders[0]);
                  sender2Gender = Global.friendManager.getFriendGender(wishSenders[1]);
                  senderNames = ZLocUtils.t("Dialogs","friendA_friendB_and_others",{
                     "userA":ZLocUtils.tn(sender1Name,ZLocUtils.tg(sender1Gender)),
                     "userB":ZLocUtils.tn(sender2Name,ZLocUtils.tg(sender2Gender))
                  });
               }
         }
         var wishListMessageTitle:String = "wishlist_granted_title";
         var wishListMessageText:String = ZLocUtils.t("Dialogs","wishlist_granted",{"users":senderNames});
         var dialogAsset:String = "assets/dialogs/FV_GenPopUpGold.swf";
         super(wishListMessageTitle,wishListMessageText,true,GenericPopup.TYPE_ACCEPTCANCEL,this.onPostFeed,dialogAsset);
         setAcceptTextName("wishlist_thank_em");
      }
      
      protected function onPostFeed(event:GenericPopupEvent) : void
      {
         var feedAction:String = null;
         var iconURL:String = null;
         var bundleData:Object = null;
         if(event.button == GenericPopup.ACCEPT)
         {
            feedAction = "WishlistReward";
            iconURL = this.m_wishImage;
            iconURL = Global.getAssetURL(iconURL);
            bundleData = {
               "reward_link":this.m_wishRewardLink,
               "item_name":this.m_wishName,
               "images":[{
                  "href":"{SN_APP_URL}" + this.m_wishRewardLink,
                  "src":iconURL
               }]
            };
            GlobalEngine.socialNetwork.publishFeedStory(feedAction,bundleData,[],false,null);
         }
      }
   }
}

