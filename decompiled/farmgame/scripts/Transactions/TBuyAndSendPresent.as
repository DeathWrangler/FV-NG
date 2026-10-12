package Transactions
{
   import Classes.Constants.StatsTrackingConstants;
   import Classes.IUser;
   import Classes.VisitorManager;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import Events.GenericPopupEvent;
   import Managers.FarmGameSettingsManager;
   import Managers.FarmStatsManager;
   import Widgets.Windows.MFSSendPaidGift;
   import Widgets.Windows.Market.MarketWindow;
   
   public class TBuyAndSendPresent extends TFarmTransaction
   {
      
      public static const ITEMCONTEXT_NORMAL:String = "normal";
      
      public static const ITEMCONTEXT_MODELFARM:String = "model_farm";
      
      public static const ITEMCONTEXT_NEIGHBORFARM:String = "neighbor_visit";
      
      public static const ITEMCONTEXT_LIMITEDGIFT:String = "limitedGift";
      
      public static const ITEMCONTEXT_EARLYACCESS:String = "EarlyAccessPaidGifting";
      
      public static const ITEMCONTEXT_PAID_GIFTING_ON_IDLE:String = "paidGiftingOnIdle";
      
      protected var m_present:FarmItem = null;
      
      protected var m_friendList:Array;
      
      protected var m_friendListUIDs:Array;
      
      protected var m_extraItemData:Object;
      
      protected var m_itemContext:String;
      
      protected var m_confirmPopup:GenericPopup = null;
      
      private var m_friendListIsIUser:Boolean = false;
      
      private var m_returnGift:Boolean = false;
      
      private var m_giftingStatsCounter:String;
      
      public function TBuyAndSendPresent(present:FarmItem, friendList:Array, itemContext:String = "normal", extraItemData:Object = null, returnGift:Boolean = false, giftingStatsCounter:String = null)
      {
         var friendIdx:int = 0;
         this.m_giftingStatsCounter = StatsTrackingConstants.MARKETPLACE_GIFTING;
         super();
         this.m_present = present;
         this.m_friendList = friendList;
         this.m_itemContext = itemContext;
         this.m_extraItemData = extraItemData;
         if(Boolean(friendList.length) && Boolean(friendList[0] as IUser))
         {
            this.m_friendListIsIUser = true;
            this.m_friendListUIDs = new Array();
            for(friendIdx = 0; friendIdx < this.m_friendList.length; friendIdx++)
            {
               this.m_friendListUIDs.push((this.m_friendList[friendIdx] as IUser).uid.toString());
            }
         }
         else
         {
            this.m_friendListUIDs = friendList;
         }
         this.m_returnGift = returnGift;
         if(giftingStatsCounter != null)
         {
            this.m_giftingStatsCounter = giftingStatsCounter;
         }
      }
      
      override public function perform() : void
      {
         if(this.m_returnGift)
         {
            signedCall("PresentService.buyAndRegift",this.m_present.code,String(this.m_friendListUIDs[0]),this.m_itemContext);
         }
         else
         {
            signedCall("PresentService.buyAndSend",this.m_present.name,this.m_friendListUIDs,this.m_itemContext,this.m_extraItemData);
         }
      }
      
      override protected function onComplete(result:Object) : void
      {
         var numPresents:int = 0;
         var cash:int = 0;
         var buyXp:int = 0;
         var isSpecialValentinesItem:Boolean = false;
         var recipient:String = null;
         var recipientGender:String = null;
         var msg:String = null;
         var sharePopup:GenericPopup = null;
         var text:String = null;
         if(result != null)
         {
            if(result.complete)
            {
               numPresents = int(this.m_friendListUIDs.length);
               if(result.numSent)
               {
                  numPresents = int(result.numSent);
               }
               cash = this.m_present.realCashCost * numPresents;
               if(result.totalCost)
               {
                  cash = int(result.totalCost);
               }
               if(cash > 0)
               {
                  Global.player.cash -= cash;
               }
               buyXp = 0;
               isSpecialValentinesItem = false;
               if(FarmGameSettingsManager.isInDataSourceExperiment())
               {
                  buyXp = this.m_present.getIntFromDataSource("buyXp");
                  isSpecialValentinesItem = this.m_present.getBoolFromDataSource("specialValentinesItem");
               }
               else
               {
                  if(Boolean(this.m_present.xml.buyXp) && this.m_present.xml.buyXp.toString() != "")
                  {
                     buyXp = int(this.m_present.xml.buyXp);
                  }
                  isSpecialValentinesItem = Boolean(this.m_present.xml.@specialValentinesItem) && true == this.m_present.xml.@specialValentinesItem;
               }
               if(buyXp > 0)
               {
                  Global.player.xp += buyXp * numPresents;
               }
               if(isSpecialValentinesItem)
               {
                  if(this.m_friendListUIDs[0] != Global.player.uid)
                  {
                     recipient = this.m_friendList[0].name;
                     recipientGender = (this.m_friendList[0] as IUser).snUser.gender;
                     msg = ZLocUtils.t("Dialogs","ValentinesPresentShareFeed",{
                        "user":ZLocUtils.tn(recipient,ZLocUtils.tg(recipientGender)),
                        "user_same":recipient
                     });
                     sharePopup = new GenericPopup(msg,GenericPopup.TYPE_SHARECANCEL,this.onShareRingFeed,GenericPopup.GENERIC_ASSET_LRG);
                     UI.displayPopup(sharePopup,false);
                  }
                  else
                  {
                     text = ZLocUtils.t("Dialogs","ringboxConfirmation");
                     UI.displayMessage(text,0,null,"",true);
                  }
               }
               else
               {
                  if(!MFSSendPaidGift.giftingV2Enabled)
                  {
                     UI.displayMessage(ZLocUtils.t("Dialogs","SendPresentFeed"),GenericPopup.TYPE_SHARECANCEL,this.onShareFeed,"",true,false,"present-presentSend");
                  }
                  FarmStatsManager.count(this.m_giftingStatsCounter,"transaction_complete");
                  FarmStatsManager.count("fv_buyableGift","sent_gift",this.m_present.name,String(cash));
                  if(this.m_itemContext == ITEMCONTEXT_MODELFARM)
                  {
                     FarmStatsManager.count(this.m_itemContext,"sent_item",this.m_present.name,String(this.m_present.cash),"","",numPresents);
                  }
                  else if(this.m_itemContext == ITEMCONTEXT_NEIGHBORFARM)
                  {
                     FarmStatsManager.count(VisitorManager.NEIGHBOR_VISIT_COUNTER,"buy_send_item",this.m_present.cashName,String(this.m_present.cash),"","",numPresents);
                  }
               }
            }
         }
      }
      
      protected function onShareRingFeed(event:GenericPopupEvent) : void
      {
         var bundleData:Object = null;
         if(event.button == GenericPopup.ACCEPT)
         {
            bundleData = {"images":[{
               "href":"{SN_APP_URL}",
               "src":this.m_present.icon
            }]};
            GlobalEngine.socialNetwork.publishFeedStory("SendValentinesPresent",bundleData,this.m_friendListUIDs,false);
         }
      }
      
      protected function onShareFeed(event:GenericPopupEvent) : void
      {
         var bundleData:Object = null;
         if(event.button == GenericPopup.ACCEPT)
         {
            bundleData = {"images":[{
               "href":"{SN_APP_URL}",
               "src":Global.getAssetURL("assets/newsfeed/presentIconFeed.png")
            }]};
            GlobalEngine.socialNetwork.publishFeedStory("SendPresent",bundleData,this.m_friendListUIDs,false,this.onFeedClose);
            FarmStatsManager.count("fv_buyableGift","accept_send_feed");
            if(this.m_itemContext != ITEMCONTEXT_NORMAL)
            {
               FarmStatsManager.count("wall_to_wall",this.m_itemContext + "_gift_sent");
            }
         }
         else if(event.button == GenericPopup.CANCEL)
         {
            this.onFeedClose();
         }
      }
      
      protected function onFeedClose() : void
      {
         var friendName:String = null;
         var msg:String = null;
         if(this.m_confirmPopup == null)
         {
            friendName = (this.m_friendList[0] as IUser).name;
            msg = null;
            if(Global.worldManager.isVisiting())
            {
               msg = ZLocUtils.t("Dialogs","Visiting_PresentSendConfirm",{
                  "user":ZLocUtils.tn(friendName),
                  "item":ZLocUtils.tk_pk(this.m_present.friendlyName)
               });
               this.m_confirmPopup = new GenericPopup(msg,GenericPopup.TYPE_OK);
               this.m_confirmPopup.setAcceptTextName("Visiting_PresentSendConfirmButton");
            }
            else
            {
               msg = ZLocUtils.t("Dialogs","PresentSendConfirm",{
                  "user":ZLocUtils.tn(friendName),
                  "item":ZLocUtils.tk_pk(this.m_present.friendlyName)
               });
               this.m_confirmPopup = new GenericPopup(msg,GenericPopup.TYPE_ACCEPTCANCEL,this.onConfirmPopupClose);
               this.m_confirmPopup.setAcceptTextName("PresentSendConfirmButton");
            }
            UI.displayPopup(this.m_confirmPopup,true,"PresentSendConfirm",true);
         }
      }
      
      protected function onConfirmPopupClose(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.YES)
         {
            UI.displayMarketDialog("buyPresent",MarketWindow.previousType,null,MarketWindow.previousSubType);
         }
         this.m_confirmPopup = null;
      }
   }
}

