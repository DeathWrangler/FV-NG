package Widgets.Windows
{
   import Classes.Animal;
   import Classes.Constants.Experiments;
   import Classes.Constants.StatsTrackingConstants;
   import Classes.Friend;
   import Classes.Plot;
   import Classes.SimpleHarvestableResource;
   import Classes.ZItem.FarmItem;
   import Classes.util.DisplayObjectUtils;
   import Classes.util.PaymentUtil;
   import Classes.util.ZLocUtils;
   import Display.GenericIconPopup;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Events.GenericPopupEvent;
   import Managers.FarmGameSettingsManager;
   import Managers.FarmStatsManager;
   import Managers.InGamePaymentsManager;
   import Transactions.TBuyAndSendPresent;
   import Transactions.TRefreshBalance;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Frames.ObjectPreviewFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.TextFields.FarmTextField;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   
   public class MarketplaceGiftingReceipt extends FarmWindow
   {
      
      protected static var m_DialogResource:String;
      
      protected var m_giftItem:FarmItem;
      
      private var m_returnItem:FarmItem;
      
      private var m_closedCallback:Function = null;
      
      private var m_giftBackCopy:String = "";
      
      private var m_activeLayout:MovieClip;
      
      private var m_senderName:String;
      
      private var m_senderUid:String;
      
      private var m_buyAndSendButton:FarmAnimatedTextButton;
      
      private var m_layoutVariant:int = 0;
      
      private var m_giftingStatsCounter:String = StatsTrackingConstants.MARKETPLACE_GIFTING;
      
      public function MarketplaceGiftingReceipt(senderUid:String, giftItem:FarmItem, returnItem:FarmItem, closeCallback:Function, giftingStatsCounter:String = null)
      {
         this.m_giftItem = giftItem;
         this.m_returnItem = returnItem;
         this.m_closedCallback = closeCallback;
         this.m_senderUid = senderUid;
         var senderFriend:Friend = Global.friendManager.getFriendData(senderUid);
         if(senderFriend)
         {
            this.m_senderName = senderFriend.firstName;
         }
         else
         {
            this.m_senderName = ZLocUtils.t("Dialogs","MarketplaceGifting_AnonymousSender");
         }
         this.m_layoutVariant = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_MARKET_GIFTING_V2_GIFTBACK_COPY);
         this.m_giftBackCopy = ZLocUtils.t("Dialogs",this.giftBackCopyIdentifier,{
            "sender":this.m_senderName,
            "itemName":returnItem.friendlyTitle,
            "itemCost":this.getRegiftItemCost()
         });
         if(!m_DialogResource)
         {
            m_DialogResource = "assets/dialogs/FV_MarketplaceGifting_Gift.swf";
         }
         if(giftingStatsCounter != null)
         {
            this.m_giftingStatsCounter = giftingStatsCounter;
         }
         super(m_DialogResource,true,false);
      }
      
      private function getRegiftItemCost() : int
      {
         var regiftVariant:int = Global.eosManager.getEosVariant(Experiments.EXPERIMENT_FLASH_MARKET_GIFTING_V2_GIFTBACK_DISCOUNT);
         var priceMultiplier:Number = 1 - (regiftVariant - 1) * 0.1;
         if(priceMultiplier > 1)
         {
            priceMultiplier = 1;
         }
         return int(Math.ceil(this.m_returnItem.cash * priceMultiplier));
      }
      
      override protected function postLoadComplete() : void
      {
         var senderPic:FarmIcon = null;
         super.postLoadComplete();
         if(m_window.mc_background)
         {
            addWidget(new ZwWidget(m_window.mc_background));
         }
         if(m_window.mc_header)
         {
            addWidget(new ZwWidget(m_window.mc_header));
         }
         if(!this.showCloseButton && Boolean(m_closeButton))
         {
            m_closeButton.visible = false;
         }
         addWidget(new FarmTextField(m_window.title_tf,ZLocUtils.t("Dialogs","MarketplaceGifting_RecvTitle")));
         if(this.showBuyAndSendInBox)
         {
            this.m_activeLayout = m_window.giftReceive_2_mc;
         }
         else
         {
            this.m_activeLayout = m_window.giftReceive_1_mc;
         }
         var activeLayout:ZwWidget = addWidget(new ZwWidget(this.m_activeLayout)) as ZwWidget;
         activeLayout.visible = true;
         this.m_buyAndSendButton = addWidget(new FarmAnimatedTextButton(this.m_activeLayout.buy_mc,ZLocUtils.t("Dialogs","MarketplaceGifting_BuyAndSend"),this.onRegift)) as FarmAnimatedTextButton;
         var buyButtonCost:FarmTextField = addWidget(new FarmTextField(this.m_activeLayout.buy_mc.fc_amount_tf,this.getRegiftItemCost().toString())) as FarmTextField;
         addWidget(new FarmTextField(this.m_activeLayout.generic_tf,ZLocUtils.t("Dialogs","MarketplaceGifting_Message",{"itemName":this.m_giftItem.friendlyTitle})));
         addWidget(new FarmTextField(this.m_activeLayout.name2_tf,this.m_senderName));
         addWidget(new FarmTextField(this.m_activeLayout.name_tf,Global.player.firstName));
         addWidget(new FarmTextField(this.m_activeLayout.generic2_tf,this.m_giftBackCopy));
         this.createObjectPreview(this.m_giftItem,this.m_activeLayout.icon_mc,1);
         this.createObjectPreview(this.m_returnItem,this.m_activeLayout.icon2_mc,0.3);
         var terrain:String = Global.farmGameSettingsManager.selectPrimaryTerrainNameFromGivenCodes(this.m_giftItem.getTerrainCodes());
         this.showTerrain(terrain,this.m_activeLayout,"_mc");
         terrain = Global.farmGameSettingsManager.selectPrimaryTerrainNameFromGivenCodes(this.m_returnItem.getTerrainCodes());
         this.showTerrain(terrain,this.m_activeLayout,"_sm_mc");
         var senderFriend:Friend = Global.friendManager.getFriendData(this.m_senderUid);
         if(senderFriend != null)
         {
            senderPic = addWidget(new FarmIcon(this.m_activeLayout.fbIcon0_mc,senderFriend.picture)) as FarmIcon;
         }
         else
         {
            addWidget(new ZwWidget(this.m_activeLayout.fbIcon0_mc),false);
         }
         if(this.m_activeLayout.okay_bt)
         {
            addWidget(new FarmAnimatedTextButton(this.m_activeLayout.okay_bt,ZLocUtils.t("Dialogs","Okay1"),this.onClose));
         }
         FarmStatsManager.count(this.m_giftingStatsCounter,"receiving_dialog","impressions");
      }
      
      private function showTerrain(terrain:String, view:MovieClip, extension:String = "_mc") : void
      {
         var ttype:String = null;
         var controlName:String = null;
         var terrainList:Array = [FarmGameSettingsManager.TERRAIN_GROUND,FarmGameSettingsManager.TERRAIN_LAND,FarmGameSettingsManager.TERRAIN_WATER,FarmGameSettingsManager.TERRAIN_SHORELINE,FarmGameSettingsManager.TERRAIN_TERRACE,FarmGameSettingsManager.TERRAIN_PLOWABLE];
         for each(ttype in terrainList)
         {
            controlName = ttype + extension;
            if(view.hasOwnProperty(controlName))
            {
               addWidget(new ZwWidget(view[controlName]),ttype == terrain);
            }
         }
      }
      
      override protected function onClose(event:Event) : void
      {
         if(event != null)
         {
            FarmStatsManager.count(this.m_giftingStatsCounter,"receiving_dialog","close_click");
         }
         if(this.m_closedCallback != null)
         {
            this.m_closedCallback();
         }
         super.onClose(event);
      }
      
      private function onRegift(event:Event) : void
      {
         FarmStatsManager.count(this.m_giftingStatsCounter,"receiving_dialog","buy_click",this.m_returnItem.name,String(this.getRegiftItemCost()));
         FarmStatsManager.count(this.m_giftingStatsCounter,"purchase_confirm","impressions");
         var confirmMsg:String = ZLocUtils.t("Dialogs","MarketplaceGifting_RegiftConfirm",{
            "cost":this.getRegiftItemCost(),
            "itemName":this.m_returnItem.friendlyTitle,
            "playerName":this.m_senderName
         });
         var confirmPopup:GenericIconPopup = new GenericIconPopup(confirmMsg,GenericPopup.TYPE_OK,this.onRegiftConfirmClose,this.m_returnItem.icon);
         UI.displayPopup(confirmPopup,false);
      }
      
      protected function onRegiftConfirmClose(event:GenericPopupEvent) : void
      {
         var farmCashAmount:int = 0;
         if(event.button == GenericPopup.YES)
         {
            FarmStatsManager.count(this.m_giftingStatsCounter,"purchase_confirm","accept_click",this.m_returnItem.name,String(this.getRegiftItemCost()));
            if(Global.player.cash >= this.getRegiftItemCost())
            {
               TransactionManager.addTransaction(new TBuyAndSendPresent(this.m_returnItem,[this.m_senderUid],TBuyAndSendPresent.ITEMCONTEXT_NORMAL,null,true,this.m_giftingStatsCounter));
               this.m_buyAndSendButton.enabled = false;
               DisplayObjectUtils.grayOut(this.m_buyAndSendButton.element as Sprite,true);
               UI.displayPopup(new MarketplaceGiftingSuccess(1,this.m_returnItem,this.onRegiftSuccess,this.m_giftingStatsCounter),false);
            }
            else
            {
               farmCashAmount = InGamePaymentsManager.getMinimumPackageSize(this.getRegiftItemCost());
               PaymentUtil.instance.addCashToCart(farmCashAmount,"MarketplaceGifting",this.onPaymentSuccess,this.onPaymentFailure);
               FarmStatsManager.count("fv_buyableGift","not_enough_cash");
            }
         }
         else
         {
            FarmStatsManager.count(this.m_giftingStatsCounter,"purchase_confirm","close_click");
         }
      }
      
      protected function onPaymentSuccess(orderId:String, status:String) : void
      {
         TransactionManager.addTransaction(new TRefreshBalance(),true);
      }
      
      protected function onPaymentFailure(errorCode:String, errorMessage:String) : void
      {
      }
      
      private function onRegiftSuccess(result:Object = null) : void
      {
         this.onClose(null);
      }
      
      private function get showCloseButton() : Boolean
      {
         return !this.showBuyAndSendInBox;
      }
      
      private function get showBuyAndSendInBox() : Boolean
      {
         return this.m_layoutVariant >= 3;
      }
      
      private function get giftBackCopyIdentifier() : String
      {
         switch(this.m_layoutVariant)
         {
            case 2:
            case 4:
               return "MarketplaceGifting_GiftBackB";
            default:
               return "MarketplaceGifting_GiftBackA";
         }
      }
      
      protected function createObjectPreview(item:FarmItem, element:MovieClip, scaleFactor:Number) : ObjectPreviewFrame
      {
         var itemState:String = "";
         var scale:Number = 2.4;
         switch(item.type)
         {
            case "seed":
            case "plot":
               itemState = Plot.STATE_GROWN;
               break;
            case "tree":
               itemState = SimpleHarvestableResource.STATE_RIPE;
               scale = 2;
               break;
            case "animal":
            case "gopher":
               itemState = Animal.STATE_FRONT_IDLE;
               scale = this.m_giftItem.sizeX == 1 ? 3.5 : 3.25;
               break;
            case "decoration":
               scale = this.m_giftItem.sizeX == 1 ? 4.5 : 2.4;
         }
         scale *= scaleFactor;
         var frame:ObjectPreviewFrame = new ObjectPreviewFrame(element,item,null,[scale],null,itemState);
         addWidget(frame,true);
         return frame;
      }
   }
}

